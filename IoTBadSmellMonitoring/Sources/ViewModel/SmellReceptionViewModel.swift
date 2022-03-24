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
    
    @Published var topRegionCode: String = ""   //상위 지역 코드
    @Published var topRegionName: String = ""   //상위 지역 명
    @Published var subRegionCode: String = ""   //하위 지역 코드
    @Published var subRegionName: String = ""   //하위 지역 명
    
    @Published var receptionTotalCount: Int = 0
    @Published var detectionCount: Int = 0
    @Published var detectionRate: Double = 0.0
    @Published var mainSmellTypeName: String = "-"
    @Published var mainSmellLevelName: String = "-"
    
    @Published var result: String = ""   //결과 상태
    @Published var message: String = "" //결과 메시지
    @Published var validMessage: String = ""    //유효성 검사 메시지
    
    //MARK: - 사용자의 지역 정보 세팅
    func setRegionInfo() {
        topRegionCode = UserDefaults.standard.string(forKey: "topRegionCode")!  //상위 지역 코드
        topRegionName = UserDefaults.standard.string(forKey: "topRegionName")!  //상위 지역 명
        subRegionCode = UserDefaults.standard.string(forKey: "subRegionCode")!  //하위 지역 코드
        subRegionName = UserDefaults.standard.string(forKey: "subRegionName")!  //하위 지역 명
    }
    
    //MARK: - 시간에 따른 날씨 화면 배경 설정
    /// - Returns: 배경 그라데이션 시작 색상, 종료 색상
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
            "userId": UserDefaults.standard.string(forKey: "userId")!   //사용자 기본값에 저장된 사용자 ID
        ]
        
        //금일 냄새 접수 현황 API 호출
        let request = smellAPI.requestTodayReception(parameters: parameters)
        request.execute(
            //API 호출 성공
            onSuccess: { (status) in
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
                            "timeZoneCode": statusData.timeZoneCode,    //접수 시간대 코드
                            "timeZone": statusData.timeZone,    //접수 시간대 00:00 ~ 00:00
                            "statusCode": statusData.status //접수 상태 코드
                        ]

                        statusArray.append(statusDictionary)
                    }
                    
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
    
    //MARK: - 사용자에 해당하는 지역 접수 통계
    func getRegionalStatistics() {
        
        //API 호출 - Request Parameters
        let parameters = [
            "regionMaster": topRegionCode,  //상위 지역 코드
            "regionDetail": subRegionCode   //하위 지역 코드
        ]
        
        //악취 접수 통계 API 호출
        let request = smellAPI.requestRegionalStatistics(parameters: parameters)
        request.execute(
            //API 호출 성공
            onSuccess: { (statistics) in
                self.result = statistics.result   //API 호출 결과 메시지
                
                if self.result == "success" {
                    let data = statistics.data!
                    
                    self.receptionTotalCount = data.receptionTotalCount //총 접수 횟수
                    self.detectionCount = data.detectionCount   //감지 횟수
                    self.detectionRate = data.detectionRate //감지 비율
                    
                    //주요 악취 명
                    if data.mainSmellTypeName == "" {
                        self.mainSmellTypeName = "-"
                    } else {
                        self.mainSmellTypeName = data.mainSmellTypeName
                    }
                    
                    //주요 악취 강도 명
                    if data.mainSmellLevelName == "" {
                        self.mainSmellLevelName = "-"
                    } else {
                        self.mainSmellLevelName = data.mainSmellLevelName
                    }
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
