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
    
    //MARK: - 악취 접수 등록 및 이미지 업로드 API 호출
    /// 악취 접수 정보 등록 및 첨부사진 이미지 업로드 API 호출
    /// - Parameters:
    ///   - parameters:
    ///     - smellValue: 악취 강도 코드
    ///     - smellType: 취기 코드
    ///     - weatherState: 기상상태 코드
    ///     - temperatureValue: 기온
    ///     - humidityValue: 습도
    ///     - windDirectionValue: 풍향 코드
    ///     - windSpeedValue: 풍속
    ///     - gpsX: X 좌표 (경도)
    ///     - gpsY: Y 좌표 (위도)
    ///     - smellComment: 추가 전달사항
    ///     - smellRegisterTime:  접수 등록 시간대
    ///     - regId: 등록자 ID
    ///   - images: 이미지 파일
    /// - Returns: API Response - Result, Message
    public func uploadReceptionRegist(parameters: [String: Any], images: [UIImage]) -> Future<Response, AFError> {
        
        return apiClient.upload(route: APIRouter.post(useApi: "base", path: "/api/registerInsert", parameters: parameters, isUpload: true), parameters: parameters, images: images)
    }
    
    //MARK: - 접수 이력 정보 API 호출
    /// 악취 접수 이력 정보 API 호출
    /// - Parameter parameters:
    ///   - regId: 등록자 ID
    ///   - startDate: 조회 시작일자
    ///   - endDate: 조회 종료일자
    ///   - smellValue: 조회 악취 강도 코드
    ///   - recordCountPerPage: 페이지 당 조회 결과 수
    ///   - firstIndex: 조회 페이지 번호
    /// - Returns: History Model
    public func requestHistory(parameters: [String: String]) -> Future<Responses<[History]>, AFError> {
        
        return apiClient.request(route: APIRouter.get(useApi: "base", path: "/api/registerMasterHistory", parameters: parameters))
    }
    
    //MARK: - 접수 이력 상세 정보 API 호출
    /// 악취 접수 이력 상세 정보 API 호출
    /// - Parameter parameters:
    ///   - smellRegisterNo: 악취 접수 등록번호
    /// - Returns: Detail History Model
    public func requestDetailHistory(parameters: [String: String]) -> Future<Responses<[DetailHistory]>, AFError> {
        
        return apiClient.request(route: APIRouter.get(useApi: "base", path: "/api/registerDetailHistory", parameters: parameters))
    }
}
