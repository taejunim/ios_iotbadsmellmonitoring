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
    ///   - userId: 사용자 ID
    ///   - userPassword: 비밀번호
    /// - Returns: User Model
    public func requestSignIn(parameters: [String: Any]) -> Future<Responses<User>, AFError> {
        
        return apiClient.request(route: APIRouter.post(useApi: "base", path: "/api/userLogin", parameters: parameters, isUpload: false))
    }
    
    //MARK: - 회원가입 API 호출
    /// 회원가입 API 호출
    /// - Parameter parameters:
    ///   - userType: 사용자 유형
    ///   - userId: 사용자 ID
    ///   - userPassword: 비밀번호
    ///   - userName: 이름
    ///   - userPhone: 휴대전화번호
    ///   - userAge: 연령
    ///   - userSex: 성별
    ///   - userRegionMaster: 상위 지역 코드
    ///   - userRegionDetail: 하위 지역 코드
    /// - Returns: API Response - Result, Message
    public func requestSignUp(parameters: [String : Any]) -> Future<Response, AFError> {
        
        return apiClient.request(route: APIRouter.post(useApi: "base", path: "/api/userJoinInsert", parameters: parameters, isUpload: false))
    }
    
    //MARK: - 사용자 정보 API 호출
    /// 사용자 정보 API 호출
    /// - Parameter parameters:
    ///   - userId: 사용자 ID
    /// - Returns: User Model
    public func requestUserInfo(parameters: [String : String]) -> Future<Responses<User>, AFError> {
        
        return apiClient.request(route: APIRouter.get(useApi: "base", path: "/api/userInfo", parameters: parameters))
    }
     
    //MARK: - ID 찾기 API 호출
    /// ID 찾기 API 호출
    /// - Parameter parameters:
    ///   - userId: 사용자 ID
    /// - Returns: API Response - Result, Message
    public func requestFindId(parameters: [String : String]) -> Future<Response, AFError> {
        
        return apiClient.request(route: APIRouter.get(useApi: "base", path: "/api/userFindId", parameters: parameters))
    }
    
    //MARK: - 비밀번호 변경 API 호출
    /// 비밀번호 변경 API 호출
    /// - Parameter parameters:
    ///   - userId: 사용자 ID
    ///   - userPassword: 비밀번호
    /// - Returns: API Response - Result, Message
    public func requestPasswordChange(parameters: [String : Any]) -> Future<Response, AFError> {

        return apiClient.request(route: APIRouter.post(useApi: "base", path: "/api/userPasswordChange", parameters: parameters, isUpload: false))
    }
    
    //MARK: - 인증 번호 API 호출
    /// 인증 번호 API 호출
    /// - Returns: API Response - Result, Message
    public func requestAuthNumber(parameters: [String : String]) -> Future<Responses<AuthNumber>, AFError> {
        
        return apiClient.request(route: APIRouter.get(useApi: "base", path: "/api/getNumberGen", parameters: parameters))
    }
    
    //MARK: - 회원탈퇴 API 호출
    /// 비밀번호 변경 API 호출
    /// - Parameter parameters:
    ///   - userId: 사용자 ID
    ///   - userPassword: 비밀번호
    /// - Returns: API Response - Result, Message
    public func deleteUser(parameters: [String : Any]) -> Future<Response, AFError> {

        return apiClient.request(route: APIRouter.post(useApi: "base", path: "/api/userDelete", parameters: parameters, isUpload: false))
    }
}


