//
//  SmellReceptionViewModel.swift
//  IoTBadSmellMonitoring
//
//  Created by KJ on 2021/06/18.
//

import Foundation
import UIKit
import Combine

class SmellReceptionViewModel: ObservableObject {
    
    private let codeViewModel = CodeViewModel() //Code View Model
    private let smellAPI = SmellAPISerivce()    //Smell API Service
    
    @Published var weatherBackground: (String, String) = ("Day.Start", "Day.End")   //날씨 배경
    @Published var receptionTimeCode: [[String: String]] = [[:]]  //접수 시간대 코드
    @Published var smellCode: [[String: String]] = [[:]]  //악취 강도 코드
    @Published var receptionStatus: [[String: String]] = [[:]]  //금일 냄새 접수 현황
    @Published var completeCount: Int = 0   //금일 접수 완료 개수
    
    @Published var result: String = ""   //결과 상태
    @Published var message: String = "" //결과 메시지
    @Published var validMessage: String = ""    //유효성 검사 메시지
    
    //MARK: - 시간에 따른 날씨 화면 배경 설정
    func setWeatherBackground() -> (String, String) {
        
        let currentTime: Int = Int("HH".dateFormatter(formatDate: Date()))!    //현재 시간
        
        //새벽(00 ~ 06시)
        if currentTime >= 0 && currentTime < 6 {
            return ("Dawn.Start", "Dawn.End")
        }
        
        //아침(06 ~ 09시)
        if currentTime >= 6 && currentTime < 9 {
            return ("Morning.Start", "Morning.End")
        }
        
        //낮(09 ~ 18시)
        if currentTime >= 9 && currentTime < 18 {
            return ("Day.Start", "Day.End")
        }
        
        //저녁(18 ~ 21시)
        if currentTime >= 18 && currentTime < 21 {
            return ("Evening.Start", "Evening.End")
        }
        
        //밤(21 ~ 24시)
        if currentTime >= 21 && currentTime < 0 {
            return ("Night.Start", "Night.End")
        }
        
        return ("Day.Start", "Day.End")
    }
    
    //MARK: - 접수 시간대 코드 API 호출
    func getReceptionTimeCode() {
        codeViewModel.getCode(codeGroup: "REN") { (code) in
            self.receptionTimeCode = code
        }
    }
    
    //MARK: - 악퀴 강도 코드
    func getSmellCode() {
        codeViewModel.getCode(codeGroup: "SMT") { (code) in
            self.smellCode = code
        }
    }
    
    //MARK: - 금일 냄새 접수 현황
    func getReceptionStatus() {
        //API 호출 - Request Parameters
        let parameters = [
            "userId": "test123" //임시
            //"userId": UserDefaults.standard.string(forKey: "userId")!
        ]
        
        //금일 냄새 접수 현황 API 호출
        let request = smellAPI.requestTodayReception(parameters: parameters)
        request.execute(
            //API 호출 성공
            onSuccess: { (status) in
                print(status)
                
                self.result = status.result   //API 호출 결과 메시지
                
                if self.result == "success" {
                    var statusDictionary: [String: String] = [:]  //Dictionary
                    var statusArray: [[String: String]] = []  //Array
                    
                    //금일 접수 현황 데이터 추출 후 Array에 할당
                    for index in 0..<status.data!.count {
                        let statusData = status.data![index]
                        
                        //금일 접수 완료 개수 Count
                        if statusData.status == "001" {
                            self.completeCount += 1
                        }

                        statusDictionary = [
                            "timeZoneCode": statusData.timeZoneCode,
                            "timeZone": statusData.timeZone,
                            "statusCode": statusData.status
                        ]

                        statusArray.append(statusDictionary)
                    }
                    
                    print(statusArray)
                    self.receptionStatus = statusArray
                }
            },
            //API 호출 실패
            onFailure: { (error) in
                self.result = "server error"
                self.message = "서버와의 통신이 원활하지 않습니다."

                print(error.localizedDescription)
            }
        )
    }
}
