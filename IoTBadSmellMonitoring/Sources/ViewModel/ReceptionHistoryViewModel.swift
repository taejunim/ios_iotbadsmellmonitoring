//
//  ReceptionHistoryViewModel.swift
//  IoTBadSmellMonitoring
//
//  Created by KJ on 2021/07/12.
//

import Foundation

class ReceptionHistoryViewModel: ObservableObject {
    private let codeViewModel = CodeViewModel() //Code View Model
    private let smellAPI = SmellAPISerivce()    //Smell API Service
    
    @Published var smellCode: [[String: String]] = [[:]]  //악취 강도 코드
    
    @Published var searchStartDate: Date = Date()
    @Published var searchEndDate: Date = Date()
    
    @Published var selectSmellCode: String = "" //선택한 악취 강도 코드
    @Published var selectSmellName: String = "" //선택한 악취 강도 명
    
    @Published var result: String = ""   //결과 상태
    @Published var message: String = "" //결과 메시지
    
    //MARK: - 악퀴 강도 코드
    func getSmellCode() {
        codeViewModel.getCode(codeGroup: "SMT") { (code) in
            self.smellCode = code
            self.selectSmellName = code[0]["codeName"]!
        }
    }
    
    func getHistory() {
        //API 호출 - Request Parameters
        let parameters = [
            //"userId": UserDefaults.standard.string(forKey: "userId")!
            "regId": "test123", //임시
            "startDate": "",
            "endDate": "",
            "smellValue": selectSmellCode,
            "recordCountPerPage": "10",
            "firstIndex": "0"
        ]
        
//        //금일 냄새 접수 현황 API 호출
//        let request = smellAPI.requestHistory(parameters: parameters)
//        request.execute(
//            //API 호출 성공
//            onSuccess: { (history) in
//                self.result = history.result   //API 호출 결과 메시지
//                
//                if self.result == "success" {
//                    
//                }
//            },
//            //API 호출 실패
//            onFailure: { (error) in
//                self.result = "server error"
//                self.message = "서버와의 통신이 원활하지 않습니다."
//
//                print(error.localizedDescription)
//            }
//        )
    }
}
