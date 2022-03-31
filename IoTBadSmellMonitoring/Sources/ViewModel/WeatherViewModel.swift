//
//  WeatherViewModel.swift
//  IoTBadSmellMonitoring
//
//  Created by KJ on 2021/06/21.
//

import Foundation
import Alamofire

class WeatherViewModel: ObservableObject {
    private let codeViewModel = CodeViewModel() //Code View Model
    
    private let commonAPI = CommonAPIService()  //공통 API Service
    private let weatherAPI = WeatherAPIService()  //기상청 날씨 API Service
    
    private let serviceKey = "aDVsltIrJTOtDLpTA6qnVPhVhaT/aciIUGI30aiipGikIAAZOI4KxfVFBqW9q3s+3xgVzKx6c3gJdUVGaNJ9Bg==" //기상청 날씨 API Service Key (Decoding)
    private let dataType = "JSON"   //데이터 타입
    
    @Published var gridX: String = "53"   //격자 X 좌표
    @Published var gridY: String = "38"   //격자 Y 좌표
    
    @Published var windDirectionCode: [[String: String]] = [[:]]  //풍향 코드
    @Published var currentWeather: [String: String] = [:]  //기상청 날씨 API 호출 데이터
    
    @Published var result: String = ""   //결과 상태
    @Published var message: String = "" //결과 메시지
    
    //MARK: - 사용자 지역의 격자 정보 API 호출
    func getGrid(completion: @escaping (_ result: String, _ gridX: String, _ gridY: String) -> Void) {

        let parameters = [
            "userRegion": UserDefaults.standard.string(forKey: "topRegionName")!    //사용자 상위 지역
        ]
        
        //지역 격자 정보 API 호출
        let request = commonAPI.requestGrid(parameters: parameters)
        request.execute(
            //API 호출 성공
            onSuccess: { (grid) in
                if grid.result == "success" {
                    self.gridX = grid.data!.gridX    //격자 X
                    self.gridY = grid.data!.gridY    //격자 Y
                }
                
                completion(grid.result, self.gridX, self.gridY)
            },
            //API 호출 실패
            onFailure: { (error) in
                completion("error", self.gridX, self.gridY)
                print(error.localizedDescription)
            }
        )
    }
    
    //MARK: - 풍향 코드 API 호출
    /// - Parameter completion: 풍향 코드 정보
    func getWindDirectionCode(completion: @escaping ([[String: String]]) -> Void) {
        codeViewModel.getCode(codeGroup: "WND") { (code) in
            completion(code)
        }
    }
    
    //MARK: - 현재 날씨 API 호출c
    /// 기상청 날씨 API 호출
    /// - Parameter completion: 가공된 현재 날씨 정보 - createCurrentWeather() 함수 참고
    func getCurrentWeather(completion: @escaping (_ gridResult: String, _ weatherInfo: [String : String]) -> Void) {
        
        getGrid() { (gridResult, gridX, gridY) in
            let baseDate: String = "yyyyMMdd".dateFormatter(formatDate: Date()) //발표일자 - yyyyMMdd
            
            let calcBaseTime: Date = Calendar.current.date(byAdding: .minute, value: -30, to: Date())!    //발표시각 = 현재 시간 - 30분
            let baseTime: String = "HH30".dateFormatter(formatDate: calcBaseTime)   //발표시각 - HH30
            
            let calcNearestTime: Date = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!  //발표시각과 가까운 시간대 = 현재 시간 + 30분
            let nearestTime: String = "HH00".dateFormatter(formatDate: calcNearestTime) //발표시각과 가까운 시간 - HH00
            
            //API 호출 - Request Body
            let parameters = [
                "serviceKey": self.serviceKey,   //서비스 인증키
                "dataType": self.dataType,   //데이터 타입
                "numOfRows": "1000",    //한 페이지 결과 수
                "base_date": baseDate,  //발표일자
                "base_time": baseTime,  //발표시각
                "nx": gridX, //예보지점 X 좌표
                "ny": gridY  //예보지점 Y 좌표
            ]
            
            //날씨 API 호출
            let request = self.weatherAPI.requestWeather(parameters: parameters)
            request.execute(
                //API 호출 성공
                onSuccess: { (weather) in
                    var weatherDictionary: [String: String] = [:]   //날씨 정보 Dictionary
                    let resultCode: String = weather.response.header.resultCode //날씨 API 조회 결과 코드
                    
                    //결과 코드 - 정상(00)
                    if resultCode == "00" {
                        self.result = "success"
                        let items = weather.response.body?.items.item   //Response Items 데이터 추출
                        
                        for index in 0..<items!.count {
                            let item = items![index]
                            
                            //현재 시간과 가장 가까운 날씨 예보 데이터 추출
                            if item.fcstTime == nearestTime {
                                let category = item.category    //자료구분 코드
                                
                                /*
                                 * - 자료구분 코드 정보
                                 *    T1H - 기온 (단위: ℃)
                                 *    SKY - 하늘상태 (맑음, 구름많음, 흐림)
                                 *    REH - 습도 (단위: %)
                                 *    PTY - 강수형태 (없음, 비, 비/눈, 눈, 소나기, 빗방울, 빗방울/눈날림, 눈날림)
                                 *    VEC - 풍향 (단위: deg)
                                 *    WSD - 풍속 (단위: m/s)
                                 */
                                //필요없는 코드정보 제외 - RN1(1시간 강수량), UUU(동서바람성분), VVV(남북바람성분), LGT(낙뢰)
                                if category != "RN1" && category != "UUU" && category != "VVV" && category != "LGT" {
                                    weatherDictionary.updateValue(item.fcstValue, forKey: item.category)
                                }
                            }
                        }
                        
                        //풍향 코드 호출 및 날씨 데이터 가공
                        self.getWindDirectionCode() { code in
                            self.windDirectionCode = code
                            completion(gridResult, self.createCurrentWeather(weatherDictionary))    //가공된 현재 날씨 데이터
                        }
                    }
                    else {
                        self.result = "fail"
                        self.message = "날씨 정보를 불러오지 못하였습니다."
                        
                        //현재 날씨 정보 - 날씨 API 오류인 경우 기본 값 설정
                        let currentWeather = [
                            "weatherState": "011",   //기상상태 코드 (011: 기타)
                            "temp": "-",   //기온
                            "humidity": "-",   //습도
                            "windDirectionCode": "-", //풍향 코드
                            "windSpeed": "-"  //풍속
                        ]
                        
                        completion(gridResult, currentWeather)
                    }
                },
                //API 호출 실패
                onFailure: { (error) in
                    self.result = "server error"
                    self.message = "서버와의 통신이 원활하지 않습니다."
                    
                    //현재 날씨 정보 - 날씨 API 오류인 경우 기본 값 설정
                    let currentWeather = [
                        "weatherState": "011",   //기상상태 코드 (011: 기타)
                        "temp": "-",   //기온
                        "humidity": "-",   //습도
                        "windDirectionCode": "-", //풍향 코드
                        "windSpeed": "-"  //풍속
                    ]
                    
                    completion(gridResult, currentWeather)
                    print(error.localizedDescription)
                }
            )
        }
    }
    
    //MARK: - 현재 날씨 정보 생성
    /// 날씨 API를 통해 추출한 날씨 데이터를 현재 날씨 화면에 출력할  데이터로 가공
    /// - Parameter weatherValues: 추출한 날씨 API 데이터 정보
    /// - Returns: 가공된 날씨 데이터 정보 - 기상상태 , 날씨 아이콘, 기온, 습도, 풍향, 풍속
    func createCurrentWeather(_ weatherValues: [String: String]) -> [String: String] {

        let skyState: String = weatherValues["SKY"]!    //하늘상태
        let precip: String = weatherValues["PTY"]!  //강수형태
        let temp: String = weatherValues["T1H"]!    //기온
        let humidity: String = weatherValues["REH"]!    //습도
        let windVector: Int = Int(weatherValues["VEC"]!)!   //풍향
        let windSpeed: String = weatherValues["WSD"]!   //풍속

        let weatherStateCode = weatherState(skyState: skyState, precip: precip).weatherStateCode    //기상상태 코드
        let weatherIcon = weatherState(skyState: skyState, precip: precip).weatherIcon  //기상상태 아이콘
        
        let convertValue: Int = Int(floor((Double(windVector) + 22.5 * 0.5) / 22.5))    //풍향 변환 값
        
        //풍향 값 계산 후 16방위로 변환
        var windDirection: String {
            return windDirectionCode[convertValue]["codeName"]!
        }
        
        //가공된 현재 날씨 정보
        let currentWeather = [
            "weatherState": weatherStateCode,   //기상상태 코드
            "weatherIcon": weatherIcon, //날씨 아이콘
            "temp": temp,   //기온
            "humidity": humidity,   //습도
            "windDirection": windDirection, //풍향
            "windDirectionCode": String(format: "%03d", convertValue),  //풍향 코드 - 풍향 변환 값 코드화
            "windSpeed": windSpeed  //풍속
        ]
        
        return currentWeather
    }
    
    //MARK: - 기상청 API의 기상상태와 강수형태 코드에 따른 기상상태 코드 및
    /// 기상청 API의 기상상태 코드와 강수형태 코드에 따른 기상상태 코드 및 기상상태 아이콘 변환
    /// - Parameters: 기상청 API 호출 데이터
    ///   - skyState: 기상청 API 기상상태 코드
    ///   - precip: 기상청 API 강수형태 코드
    /// - Returns: 기상상태 코드, 기상상태 아이콘
    func weatherState(skyState: String, precip: String) -> (weatherStateCode: String, weatherIcon: String) {
        
        let currentTime: Int = Int("HH".dateFormatter(formatDate: Date()))!    //현재 시간
        var weatherStateCode: String = "011"    //기상상태 코드 (011: 기타)
        var weatherIcon: String = "Sun" //기상상태 아이콘
        
        //강수 형태 코드 "0" = 강수 형태 없음
        if precip == "0" {
            switch skyState {
            case "1":
                weatherStateCode = "001"    //기상상태 코드 (001: 맑음)
                
                //시간에 따른 아이콘 선택
                if currentTime >= 6 && currentTime < 18 {
                    weatherIcon = "Sun"
                } else {
                    weatherIcon = "Moon"
                }
            case "3":
                weatherStateCode = "002"    //기상상태 코드 (002: 구름많음)
                
                if currentTime >= 6 && currentTime < 18 {
                    weatherIcon = "Cloud.Sun"
                } else {
                    weatherIcon = "Cloud.Moon"
                }
            case "4":
                weatherStateCode = "003"    //기상상태 코드 (003: 흐림)
                weatherIcon = "Cloud"
            default:
                weatherStateCode = "011"    //기상상태 코드 (011: 기타)
                
                if currentTime >= 6 && currentTime < 18 {
                    weatherIcon = "Sun"
                } else {
                    weatherIcon = "Moon"
                }
            }
        }
        else {
            switch precip {
            case "1":
                weatherStateCode = "004"    //기상상태 코드 (004: 비)
                weatherIcon = "Rain"
            case "2":
                weatherStateCode = "005"    //기상상태 코드 (005: 비/눈 - 진눈개비)
                weatherIcon = "Sleet"
            case "3":
                weatherStateCode = "006"    //기상상태 코드 (006: 눈)
                weatherIcon = "Snow"
            case "4":
                weatherStateCode = "007"    //기상상태 코드 (007: 소나기)

                if currentTime >= 6 && currentTime < 18 {
                    weatherIcon = "Shower.Sun"
                } else {
                    weatherIcon = "Shower.Moon"
                }
            case "5":
                weatherStateCode = "008"    //기상상태 코드 (008: 빗방울)
                
                if currentTime >= 6 && currentTime < 18 {
                    weatherIcon = "Drizzle.Sun"
                } else {
                    weatherIcon = "Drizzle.Moon"
                }
            case "6":
                weatherStateCode = "009"    //기상상태 코드 (009: 빗방울/눈날림)
                weatherIcon = "Sleet"
            case "7":
                weatherStateCode = "010"    //기상상태 코드 (010: 눈날림)
                weatherIcon = "Snow"
            default:
                weatherStateCode = "011"    //기상상태 코드 (011: 기타)
                
                if currentTime >= 6 && currentTime < 18 {
                    weatherIcon = "Sun"
                } else {
                    weatherIcon = "Moon"
                }
            }
        }
        
        return (weatherStateCode, weatherIcon)
    }
}
