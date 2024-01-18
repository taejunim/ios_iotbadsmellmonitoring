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
    func getCode(codeGroup: String, completion: @escaping ([[String : String]]) -> Void) {
        
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
                    var codeDictionary: [String : String] = [:]  //Dictionary
                    var codeArray: [[String : String]] = []  //Array
                    
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
    
    //MARK: - 현재 시간(서버 시간 기준) API 호출
    /// 서버 시간 기준의 현재 시간 API 호출
    /// - Parameter completion: Current Date
    func getCurrentDate(completion: @escaping (String) -> Void) {
        
        let request = codeAPI.requestCurrentDate()
        request.execute(
            //API 호출 성공
            onSuccess: { (date) in
                let _ = print("currentDate : " + date.data!)
                completion(date.data!)
            },
            //API 호출 실패
            onFailure: { (error) in
                completion("")
                print(error.localizedDescription)
            }
        )
    }
    
    //MARK: - 지역 코드 정보 API 호출
    /// 지역 코드 정보 목록 API 호출
    /// 상위 지역, 하위 지역의 코드 정보로 분류
    /// - Parameter completion:
    ///   - Top Regions: 상위 지역 코드 정보 목록
    ///   - Sub Regions: 하위 지역 코드 정보 목록
    func getRegion(completion: @escaping (_ topRegions: [[String : String]], _ subRegions: [[String : String]]) -> Void) {
        
        let request = codeAPI.requestRegionCode()
        request.execute(
            //API 호출 성공
            onSuccess: { (response) in
                self.result = response.result   //API 호출 결과 메시지
                
                var topRegion: [String : String] = [:]  //상위 지역 코드 정보
                var topRegions: [[String : String]] = []    //상위 지역 코드 정보 목록
                
                var subRegion: [String : String] = [:]  //하위 지역 코드 정보
                var subRegions: [[String : String]] = []    //하위 지역 코드 정보 목록
                
                if self.result == "success" {
                    let getTopRegions = response.data!.region.topRegion //상위 지역 코드 목록 추출
                    
                    //호출한 API 지역 코드 목록에서 상위 지역 코드 정보 추출
                    for getTopRegion in getTopRegions {
                        let topRegionCode = getTopRegion.code   //상위 지역 코드
                        let topRegionName = getTopRegion.codeName   //상위 지역 코드명
                        
                        topRegion = [
                            "code": topRegionCode,
                            "codeName": topRegionName
                        ]
                        
                        topRegions.append(topRegion)    //상위 지역 코드 정보 목록 추가
                        
                        let getSubRegions = getTopRegion.subRegion  //하위 지역 코드 목록 추출
                        
                        //호출한 API 지역 코드 목록에서 하위 지역 코드 정보 추출
                        for getSubRegion in getSubRegions {
                            let subRegionCode = getSubRegion.code   //하위 지역 코드
                            let subRegionName = getSubRegion.codeName   //하위 지역 코드명
                            
                            subRegion = [
                                "topRegion": topRegionCode, //하위 지역에 해당하는 상위 지역 코드
                                "code": subRegionCode,
                                "codeName": subRegionName
                            ]
                            
                            subRegions.append(subRegion)    //하위 지역 코드 정보 목록 추가
                        }
                    }
                    
                    completion(topRegions, subRegions)
                }
            },
            //API 호출 실패
            onFailure: { (error) in
                self.result = "server error"
                self.message = "서버와의 통신이 원활하지 않습니다."
                
                completion([[:]], [[:]])
                print(error.localizedDescription)
            }
        )
    }
}
