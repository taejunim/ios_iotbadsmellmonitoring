//
//  UserAPIService.swift
//  IoTBadSmellMonitoring
//
//  Created by KJ on 2021/06/07.
//

import Alamofire
import PromisedFuture

//MARK: - 사용자 API Service
class UserAPIService {
    
    let apiClient = APIClient() //API Client - 공통 API 호출
    
    //MARK: - 로그인 API 호출
    /// 로그인 API 호출
    /// - Parameter parameters:
    ///   - User ID
    ///   - Password
    /// - Returns: User Model
    public func requestSignIn(parameters: [String: Any]) -> Future<Responses<User>, AFError> {
        
        return apiClient.request(route: APIRouter.post(useApi: "base", path: "/api/userLogin", parameters: parameters))
    }
    
    
    //MARK: - 회원가입 API 호출
    /// 회원가입 API 호출
    /// - Parameter parameters:
    ///   - User Type
    ///   - User ID
    ///   - Password
    ///   - User Name
    ///   - Age
    ///   - Sex Code
    ///   - Region Code
    /// - Returns: API Response - Result, Message
    public func requestSignUp(parameters: [String: Any]) -> Future<Response, AFError> {
        
        return apiClient.request(route: APIRouter.post(useApi: "base", path: "/api/userJoinInsert", parameters: parameters))
    }
     
    //MARK: - ID 찾기 API 호출
    /// ID 찾기 API 호출
    /// - Parameter parameters: User ID
    /// - Returns: API Response - Result, Message
    public func requestFindId(parameters: [String: String]) -> Future<Response, AFError> {
        
        return apiClient.request(route: APIRouter.get(useApi: "base", path: "/api/userFindId", parameters: parameters))
    }
    //MARK: - 비밀번호 변경 API 호출
    // 비밀번호 변경 API 호출
    // - Parameter parameters:
    //   - User ID
    //   - Password
    // - Returns: User Model
    public func requestPasswordChange(parameters: [String: Any]) -> Future<Response, AFError> {

        return apiClient.request(route: APIRouter.post(useApi: "base", path: "/api/userPasswordChange", parameters: parameters))
    }
}


