//
//  ReceptionRegistViewModel.swift
//  IoTBadSmellMonitoring
//
//  Created by KJ on 2021/06/25.
//

import Foundation

class ReceptionRegistViewModel: ObservableObject {
    private let codeViewModel = CodeViewModel() //Code View Model
    private let smellAPI = SmellAPISerivce()    //Smell API Service
    
    @Published var smellTyepCode: [[String: String]] = [[:]]  //악취 취기 코드
    
    @Published var currentWeather: [String: String] = [:]
    @Published var selectSmellCode: String = ""
    @Published var selectSmellType: String = ""
    @Published var selectTempSmellType: String = ""
    @Published var addMessage: String = ""
    
    @Published var result: String = ""   //결과 상태
    @Published var message: String = "" //결과 메시지
    @Published var validMessage: String = ""    //유효성 검사 메시지
    
    //MARK: - 악취 취기 코드 API 호출
    func getSmellTypeCode() {
        codeViewModel.getCode(codeGroup: "STY") { (code) in
            self.smellTyepCode = code
        }
    }
}
    

