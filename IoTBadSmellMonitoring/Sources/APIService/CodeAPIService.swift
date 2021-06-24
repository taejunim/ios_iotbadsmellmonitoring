//
//  CodeAPIService.swift
//  IoTBadSmellMonitoring
//
//  Created by KJ on 2021/06/14.
//

import Alamofire
import PromisedFuture

//MARK: - 코드 API Service
class CodeAPIService {
    
    let apiClient = APIClient() //API Client - 공통 API 호출
    
    //MARK: - 코드 API 호출
    /// 코드 정보 API 호출
    /// - Parameter parameters: Code Group ID
    /// - Returns: Code Model
    public func requestCode(parameters: [String: String]) -> Future<Responses<[Code]>, AFError> {
        
        return apiClient.request(route: APIRouter.get(useApi: "base", path: "/api/codeListSelect", parameters: parameters))
    }
}
