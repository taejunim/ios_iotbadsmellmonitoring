//
//  ReceptionRegistViewModel.swift
//  IoTBadSmellMonitoring
//
//  Created by KJ on 2021/06/25.
//

import Foundation
import CoreLocation

class ReceptionRegistViewModel: ObservableObject {
    private let location = Location()
    private let codeViewModel = CodeViewModel() //Code View Model
    private let weatherViewModel = WeatherViewModel() //Weather View Model
    private let smellAPI = SmellAPISerivce()    //Smell API Service
    
    @Published var smellTyepCode: [[String: String]] = [[:]]  //악취 취기 코드
    
    @Published var weatherInfo: [String: String] = [:]   //날씨 정보
    @Published var selectSmellCode: String = "" //선택한 악취 강도 코드
    @Published var selectSmellType: String = "" //선택한 취기 코드
    @Published var selectTempSmellType: String = "" //선택한 임시 취기 코드
    @Published var addMessage: String = ""  //추가 전달사항
    
    @Published var result: String = ""   //결과 상태
    @Published var message: String = "" //결과 메시지
    @Published var validMessage: String = ""    //유효성 검사 메시지
    
    //MARK: - 악취 취기 코드 API 호출
    func getSmellTypeCode() {
        codeViewModel.getCode(codeGroup: "STY") { (code) in
            self.smellTyepCode = code
        }
    }
    
    //MARK: - 사용자의 현재 위치 정보 호출
    func getLocation() -> (latitude: String?, longitude: String?) {
        var latitude: String?  //위도
        var longitude: String? //경도
        
        location.startLocation()    //위치 정보 호출
        
        //위치 정보를 통해 가져온 위치 정보 값이 Null이 아닐 경우 String 변환
        if location.latitude != nil && location.longitude != nil {
            latitude = String(self.location.latitude!)  //위치 정보 위도 값
            longitude = String(self.location.longitude!)    //위치 정보 경도 값
        }
        
        return (latitude, longitude)
    }
    
    //현재 시간에 따른 접수 시간대 코드
    var timeZoneCode: String? {
        let currentTime: Int = Int("HH00".dateFormatter(formatDate: Date()))!    //현재 시간
        
        //현재 시간에 따른 접수 등록 시간대 코드
        if currentTime >= 0700 && currentTime < 0900 {
            return "001"
        }
        else if currentTime >= 1200 && currentTime < 1400 {
            return "002"
        }
        else if currentTime >= 1800 && currentTime < 2000 {
            return "003"
        }
        else if currentTime >= 2200 && currentTime < 0000 {
            return "004"
        }
        else {
            //return nil
            return "004"
        }
    }
    
    //MARK: - 악취 접수 등록 실행
    func registReception(completion: @escaping (String) -> Void) {
        let coordinate = getLocation()    //현재 위치 정보 호출

        let registTimeZone = timeZoneCode  //접수 등록 시간대 코드
            
        //현재 날씨 API 호출
        weatherViewModel.getCurrentWeather() { (weather) in
            self.weatherInfo = weather
            
            let weatherState: String = self.weatherInfo["weatherState"]!    //기상상태 코드
            let temp: String = self.weatherInfo["temp"]!    //기온
            let humidity: String = self.weatherInfo["humidity"]!    //습도
            let windDirectionCode: String = self.weatherInfo["windDirectionCode"]!  //풍향 코드
            let windSpeed: String = self.weatherInfo["windSpeed"]!  //풍속

            //API 호출 - Request Body
            let parameters = [
                "smellValue": self.selectSmellCode, //악취 강도 코드
                "smellType": self.selectSmellType,  //취기 코드
                "weatherState": weatherState,   //기상상태 코드
                "temperatureValue": temp,   //기온
                "humidityValue": humidity,  //습도
                "windDirectionValue": windDirectionCode,    //풍향 코드
                "windSpeedValue": windSpeed,    //풍속
                "gpsX": coordinate.longitude!,  //x 좌표 - 경도
                "gpsY": coordinate.latitude!,   //y 좌표 - 위도
                "smellComment": self.addMessage,    //추가 전달사항
                "smellRegisterTime": registTimeZone!,    //접수 등록 시간대
                "regId": UserDefaults.standard.string(forKey: "userId") ?? "test123"    //등록자 ID
            ]
            
            print(parameters)
            
            self.result = "success"
            self.message = "정상적으로 악취 접수가 등록되었습니다."
            
            completion(self.result)

            //악취 접수 등록 API 호출
            let request = self.smellAPI.requestReceptionRegist(parameters: parameters)
            request.execute(
                //API 호출 성공
                onSuccess: { (regist) in
                    //접수 등록 성공
                    if regist.result == "success" {
                        self.result = regist.result
                        self.message = "정상적으로 악취 접수가 등록되었습니다."
                    }
                    //접수 등록 실패
                    else {
                        self.result = regist.result
                        self.message = "악취 접수 등록이 실패하였습니다."
                    }
                    
                    completion(self.result)
                },
                //API 호출 실패
                onFailure: { (error) in
                    self.result = "server error"
                    self.message = "서버와의 통신이 원활하지 않습니다."
                    
                    completion(self.result)
                    print(error.localizedDescription)
                }
            )
        }
    }
    
    //MARK: - 접수 시간대 유효성 검사
    func isTimeZoneValid() -> Bool {
        let registTimeZone: String? = timeZoneCode
        
        //접수 등록 시간대 확인
        if registTimeZone == nil {
            self.result = "time zone mismatch"
            self.validMessage = "현재 접수 등록 가능한 시간이 아닙니다."

            return false
        }
        
        return true
    }
}
    

