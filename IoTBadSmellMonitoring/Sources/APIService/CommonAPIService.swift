//
//  CommonAPIService.swift
//  IoTBadSmellMonitoring
//
//  Created by KJ on 2022/03/16.
//

import Alamofire
import PromisedFuture

class CommonAPIService {
    let apiClient = APIClient() //API Client - 공통 API 호출
    
    //MARK: - 공지사항 API 호출
    /// 공지사항 API 호출
    /// - Returns: Notice Model
    public func requestNotice() -> Future<Responses<Notice>, AFError> {
        
        return apiClient.request(route: APIRouter.get(useApi: "base", path: "/api/noticeInfo", parameters: [:]))
    }
    
    //MARK: - 지역 격자 정보(격자 X, Y) API 호출
    /// 기상청 초단계 예보 조회를 위한 격자  X, Y 위치 정보 API 호출
    /// - Parameter parameters:
    ///   - userRegion: 사용자의 상위 지역 코드
    /// - Returns: User Coordinate Model
    public func requestGrid(parameters: [String : String]) -> Future<Responses<GridCoordinates>, AFError> {
        
        return apiClient.request(route: APIRouter.get(useApi: "base", path: "/api/userWeather", parameters: parameters))
    }
}
