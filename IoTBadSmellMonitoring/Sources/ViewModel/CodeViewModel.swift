//
//  CodeViewModel.swift
//  IoTBadSmellMonitoring
//
//  Created by KJ on 2021/06/14.
//

import Foundation
import Alamofire

class CodeViewModel: ObservableObject {
    private let codeAPI = CodeAPIService()  //코드 API Service
    
    @Published var result: String = ""   //결과 상태
    @Published var message: String = "" //결과 메시지
    
    //MARK: - 코드 API 호출
    /// 코드 정보 API 호출
    /// - Parameters:
    ///   - codeGroup: 조회할 코드 그룹
    ///   - completion: JSON 데이터를 추출하여 Dictionary Array 변환
    func getCode(codeGroup: String, completion: @escaping ([[String: String]]) -> Void) {
        
        //API 호출 - Request Body
        let parameters = [
            "codeGroup": codeGroup
        ]
        
        //코드 API 호출
        let request = codeAPI.requestCode(parameters: parameters)
        request.execute(
            //API 호출 성공
            onSuccess: { (code) in
                self.result = code.result   //API 호출 결과 메시지
                
                if self.result == "success" {
                    var codeDictionary: [String: String] = [:]  //Dictionary
                    var codeArray: [[String: String]] = []  //Array
                    
                    //코드 데이터 추출 후 Array에 할당
                    for index in 0..<code.data!.count {
                        let codeData = code.data![index]

                        codeDictionary = [
                            "code": codeData.codeId,    //코드
                            "codeName": codeData.codeIdName, //코드 명
                            "codeComment": codeData.codeComment //코드 설명
                        ]

                        codeArray.append(codeDictionary)
                    }
                    
                    completion(codeArray)
                }
            },
            //API 호출 실패
            onFailure: { (error) in
                self.result = "server error"
                self.message = "서버와의 통신이 원활하지 않습니다."
                
                completion([[:]])
                print(error.localizedDescription)
            }
        )
    }
}
