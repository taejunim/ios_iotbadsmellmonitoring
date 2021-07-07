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
    
    private let weatherAPI = WeatherAPIService()  //기상청 날씨 API Service
    private let serviceKey = "dFNlgyX4FFci5kW2VH/nG6IIFGt8NR2vvkjUw3C5RfN8IOUY1xE9D0HzzraWWPJpPfMUgjc55LHj4NCsQVRxwQ=="   //기상청 날씨 API Service Key (Decoding)
    private let dataType = "JSON"   //데이터 타입
    
    @Published var windDirectionCode: [[String: String]] = [[:]]  //풍향 코드
    @Published var currentWeather: [String: String] = [:]  //기상청 날씨 API 호출 데이터
    
    @Published var result: String = ""   //결과 상태
    @Published var message: String = "" //결과 메시지
    
    //MARK: - 풍향 코드 API 호출
    func getWindDirectionCode(completion: @escaping ([[String: String]]) -> Void) {
        codeViewModel.getCode(codeGroup: "WND") { (code) in
            completion(code)
        }
    }
    
    //MARK: - 현재 날씨 API 호출
    /// 기상청 날씨 API 호출
    /// - Parameter completion: 가공된 현재 날씨 정보 - createCurrentWeather() 함수 참고
    func getCurrentWeather(completion: @escaping ([String: String]) -> Void) {
        
        let baseDate: String = "yyyyMMdd".dateFormatter(formatDate: Date()) //발표일자 - yyyyMMdd
        
        let calcBaseTime: Date = Calendar.current.date(byAdding: .minute, value: -30, to: Date())!    //발표시각 = 현재 시간 - 30분
        let baseTime: String = "HH30".dateFormatter(formatDate: calcBaseTime)   //발표시각 - HH30
        
        let calcNearestTime: Date = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!  //발표시각과 가까운 시간대 = 현재 시간 + 30분
        let nearestTime: String = "HH00".dateFormatter(formatDate: calcNearestTime) //발표시각과 가까운 시간 - HH00
        
        //API 호출 - Request Body
        let parameters = [
            "serviceKey": serviceKey,   //서비스 인증키
            "dataType": dataType,   //데이터 타입
            "numOfRows": "1000",    //한 페이지 결과 수
            "base_date": baseDate,  //발표일자
            "base_time": baseTime,  //발표시각
            "nx": "48", //예보지점 X 좌표
            "ny": "36"  //예보지점 Y 좌표
        ]
        
        //날씨 API 호출
        let request = weatherAPI.requestWeather(parameters: parameters)
        request.execute(
            //API 호출 성공
            onSuccess: { (weather) in
                
                var weatherDictionary: [String: String] = [:]
                
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
                        completion(self.createCurrentWeather(weatherDictionary))    //가공된 현재 날씨 데이터
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
                    
                    completion(currentWeather)
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
                
                completion(currentWeather)
                print(error.localizedDescription)
            }
        )
    }
    
    //MARK: - 현재 날씨 정보 생성
    /// 날씨 API를 통해 추출한 날씨 데이터를 현재 날씨 화면에 출력할  데이터로 가공
    /// - Parameter weatherValues: 추출한 날씨 API 데이터 정보
    /// - Returns: 가공된 날씨 데이터 정보 - 기상상태 , 날씨 아이콘, 기온, 습도, 풍향, 풍속
    func createCurrentWeather(_ weatherValues: [String: String]) -> [String: String] {

        let currentTime: Int = Int("HH".dateFormatter(formatDate: Date()))!    //현재 시간
        
        let skyState: String = weatherValues["SKY"]!    //하늘상태
        let precip: String = weatherValues["PTY"]!  //강수형태
        let temp: String = weatherValues["T1H"]!    //기온
        let humidity: String = weatherValues["REH"]!    //습도
        let windVector: Int = Int(weatherValues["VEC"]!)!   //풍향
        let windSpeed: String = weatherValues["WSD"]!   //풍속

        var weatherStateCode: String = "011"    //기상 상태 코드 (011: 기타)
        
        //날씨 아이콘
        var weatherIcon: String {
            //강수 형태 코드 "0" = 강수 형태 없음
            if precip == "0" {
                switch skyState {
                case "1":   //맑음
                    weatherStateCode = "001"
                    
                    //시간에 따른 아이콘 선택
                    if currentTime >= 6 && currentTime < 18 {
                        return "sun.max.fill"
                    } else {
                        return "moon.fill"
                    }
                case "3":    //구름많음
                    weatherStateCode = "002"
                    
                    if currentTime >= 6 && currentTime < 18 {
                        return "cloud.sun.fill"
                    } else {
                        return "cloud.moon.fill"
                    }
                case "4":   //흐림
                    weatherStateCode = "003"
                    return"cloud.fill"
                default:
                    weatherStateCode = "011"
                    return "sun.max.fill"
                }
            }
            else {
                switch precip {
                case "1":   //비
                    weatherStateCode = "004"
                    return "cloud.rain.fill"
                case "2":   //비/눈 - 진눈개비
                    weatherStateCode = "005"
                    return "cloud.sleet.fill"
                case "3":   //눈
                    weatherStateCode = "006"
                    return "cloud.snow.fill"
                    
                case "4":   //소나기
                    weatherStateCode = "007"
                    return "cloud.rain.fill"
                    
                case "5":   //빗방울
                    weatherStateCode = "008"
                    return "cloud.drizzle.fill"
                    
                case "6":   //빗방울/눈날림
                    weatherStateCode = "009"
                    return "cloud.sleet.fill"
                    
                case "7":   //눈날림
                    weatherStateCode = "010"
                    return "cloud.snow.fill"
                default:
                    weatherStateCode = "011"
                    return "cloud.rain.fill"
                }
            }
        }
        
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
        
        //print(currentWeather)
        
        return currentWeather
    }
}
