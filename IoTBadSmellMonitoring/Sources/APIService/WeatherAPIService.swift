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
    /// <#Description#>
    /// - Parameter parameters: <#parameters description#>
    /// - Returns: <#description#>
    public func requestWeather(parameters: [String: String]) -> Future<Weather, AFError> {
        
        return apiClient.request(route: APIRouter.get(useApi: "weather", path: "/VilageFcstInfoService/getUltraSrtFcst", parameters: parameters))
    }
}
