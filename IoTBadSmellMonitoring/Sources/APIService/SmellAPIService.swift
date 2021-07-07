//
//  SmellAPIService.swift
//  IoTBadSmellMonitoring
//
//  Created by KJ on 2021/06/21.
//

import Alamofire
import PromisedFuture

//MARK: - 악취 관련 API Service
class SmellAPISerivce {
    
    let apiClient = APIClient() //API Client - 공통 API 호출
    
    //MARK: - 금일 냄새 접수 현황 API 호출
    /// 금일 냄새 접수 현황 API 호출
    /// - Parameter parameters: User ID
    /// - Returns: Today Reception Model
    public func requestTodayReception(parameters: [String: String]) -> Future<Responses<[TodayReception]>, AFError> {
        
        return apiClient.request(route: APIRouter.get(useApi: "base", path: "/api/userTodayRegisterInfo", parameters: parameters))
    }

    //MARK: - 악취 접수 등록 API 호출
    /// 악취 접수 등록 API 호출
    /// - Parameter parameters:
    /// - Returns: API Response - Result, Message
    public func requestReceptionRegist(parameters: [String: Any]) -> Future<Response, AFError> {
        
        return apiClient.request(route: APIRouter.post(useApi: "base", path: "/api/registerInsert", parameters: parameters))
    }
}
