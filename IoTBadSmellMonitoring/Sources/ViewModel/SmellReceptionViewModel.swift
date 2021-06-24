//
//  SmellReceptionViewModel.swift
//  IoTBadSmellMonitoring
//
//  Created by KJ on 2021/06/18.
//

import Foundation

class SmellReceptionViewModel: ObservableObject {
    private let codeViewModel = CodeViewModel() //Code View Model
    private let smellAPI = SmellAPISerivce()    //Smell API Service
    
    @Published var weatherBackground: (String, String) = ("Day.Start", "Day.End")
    @Published var receptionTimeCode: [[String: String]] = [[:]]  //접수 시간대 코드
    @Published var smellCode: [[String: String]] = [[:]]  //악취 강도 코드
    
    @Published var result: String = ""   //결과 상태
    @Published var message: String = "" //결과 메시지
    @Published var validMessage: String = ""    //유효성 검사 메시지
    
    func setWeatherBackground() -> (String, String) {
        
        let currentTime: Int = Int("HH".dateFormatter(formatDate: Date()))!    //현재 시간
        
        if currentTime >= 0 && currentTime < 6 {
            return ("Dawn.Start", "Dawn.End")
        }
        
        if currentTime >= 6 && currentTime < 9 {
            return ("Morning.Start", "Morning.End")
        }
        
        if currentTime >= 9 && currentTime < 18 {
            return ("Day.Start", "Day.End")
        }
        
        if currentTime >= 18 && currentTime < 21 {
            return ("Evening.Start", "Evening.End")
        }
        
        if currentTime >= 21 && currentTime < 0 {
            return ("Night.Start", "Night.End")
        }
        
        //.background(viewUtil.gradient("Dawn.Start", "Dawn.End", .top, .bottom)) //새벽(00~06시)
        //.background(viewUtil.gradient("Morning.Start", "Morning.End", .top, .bottom)) //아침(06~09시)
        //.background(viewUtil.gradient("Day.Start", "Day.End", .top, .bottom)) //낮(09~18시)
        //.background(viewUtil.gradient("Evening.Start", "Evening.End", .top, .bottom))   //저녁(18~21시)
        //.background(viewUtil.gradient("Night.Start", "Night.End", .top, .bottom)) //밤(21~24시)
        
        return ("1", "2")
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
       
    }
}
