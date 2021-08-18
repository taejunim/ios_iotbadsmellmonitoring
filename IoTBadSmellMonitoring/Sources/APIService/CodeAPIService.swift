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
    
    //MARK: - 현재 시간(서버 시간 기준) API 호출
    /// 서버 시간 기준의 현재 시간 API 호출
    /// - Returns: Current Date Model
    public func requestCurrentDate() -> Future<CurrentDate, AFError> {
        
        return apiClient.request(route: APIRouter.get(useApi: "base", path: "/api/currentDate", parameters: [:]))
    }
}
