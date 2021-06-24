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
    
    @Published var receptionTimeCode: [[String: String]] = [[:]]  //접수 시간대 코드
    @Published var smellCode: [[String: String]] = [[:]]  //악취 강도 코드
    
    @Published var result: String = ""   //결과 상태
    @Published var message: String = "" //결과 메시지
    @Published var validMessage: String = ""    //유효성 검사 메시지
    
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
