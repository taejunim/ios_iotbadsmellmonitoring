//
//  WeatherAPIService.swift
//  IoTBadSmellMonitoring
//
//  Created by KJ on 2021/06/21.
//

import Alamofire
import PromisedFuture

//MARK: - 날씨 API Service
class WeatherAPIService {
    
    let apiClient = APIClient() //API Client - 공통 API 호출
    
    //MARK: - 기상청 초단기 예보 API 호출
    /// 기상청 초단 예보 조회 API
    /// - Parameter parameters:
    ///   - serviceKey: 서비스 인증기
    ///   - dataType: 데이터 타입
    ///   - numOfRows: 한 페이지 결과 수
    ///   - base_date: 발표일자
    ///   - base_time: 발표시각
    ///   - nx: 예보지점 X 좌표
    ///   - ny: 예보지점 Y 좌표
    /// - Returns: Weather Model
    public func requestWeather(parameters: [String: String]) -> Future<Weather, AFError> {
        
        return apiClient.request(route: APIRouter.get(useApi: "weather", path: "/VilageFcstInfoService/getUltraSrtFcst", parameters: parameters))
    }
}
