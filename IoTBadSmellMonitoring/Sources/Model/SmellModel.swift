//
//  SmellModel.swift
//  IoTBadSmellMonitoring
//
//  Created by KJ on 2021/06/21.
//

import Foundation

//MARK: - 지역 접수 통계 정보
struct RegionalStatistics: Codable {
    let topRegionCode: String   //상위 지역 코드
    let topRegionName: String   //상위 지역 명
    let subRegionCode: String   //하위 지역 코드
    let subRegionName: String   //하위 지역 명
    
    let mainSmellTypeCode: String   //주요 악취 코드
    let mainSmellTypeName: String   //주요 악취 명
    let mainSmellLevelCode: String  //주요 악취 강도 코드
    let mainSmellLevelName: String  //주요 악취 강도 명
    
    let receptionTotalCount: Int    //총 접수 횟수
    let detectionCount: Int //감지 횟수
    let detectionRate: Double   //감지 비율(%)
    
    let smellRegisterTime: String
    let smellRegisterTimeName: String
    
    enum CodingKeys: String, CodingKey {
        case topRegionCode = "userRegionMaster"
        case topRegionName = "userRegionMasterName"
        case subRegionCode = "userRegionDetail"
        case subRegionName = "userRegionDetailName"
        
        case mainSmellTypeCode = "mainSmellType"
        case mainSmellTypeName = "mainSmellTypeName"
        case mainSmellLevelCode = "mainSmellValue"
        case mainSmellLevelName = "mainSmellValueName"
        
        case receptionTotalCount = "userTotalCount"
        case detectionCount = "userRegisterCount"
        case detectionRate = "userRegisterPercentage"
        
        case smellRegisterTime
        case smellRegisterTimeName
    }
}

//MARK: - 금일 접수 현황 정보
struct TodayReception: Codable {
    let timeZoneCode: String    //접수 시간대 코드
    let timeZone: String    //접수 시간대 00:00 ~ 00:00
    let status: String  //접수 상태
    let receptionDate: String   //접수 일자
    
    //Response JSON Key와 변수명 매칭
    enum CodingKeys: String, CodingKey {
        case timeZoneCode = "smellRegisterTime"
        case timeZone = "smellRegisterTimeName"
        case status = "resultCode"
        case receptionDate = "regDt"
    }
}

//MARK: - 접수 이력 정보
struct History: Codable {
    let registNo: String    //접수 등록번호
    let userId: String  //등록자 ID
    let userName: String    //등록자 명
    let registDate: String  //접수 등록일시

    let timeZoneCode: String    //접수 시간대 코드
    let timeZone: String    //접수 시간대

    let smellLevelCode: String  //악취 강도 코드
    let smellLevelName: String  //악취 강도 명
    let smellTypeCode: String   //취기 코드
    let smellTypeName: String   //취기 명

    let weatherStateCode: String    //기상상태 코드
    let weatherState: String    //기상상태
    let temperature: String //기온
    let humidity: String    //습도
    let windDirectionCode: String   //풍향 코드
    let windDirection: String   //풍향
    let windSpeed: String   //풍속

    let longitude: String   //GPS x 좌표
    let latitude: String    //GPS y 좌표
    let comment: String //추가 전달사항
    
    enum CodingKeys: String, CodingKey {
        case registNo = "smellRegisterNo"
        case userId = "regId"
        case userName = "userName"
        case registDate = "regDt"
        
        case timeZoneCode = "smellRegisterTime"
        case timeZone = "smellRegisterTimeName"
        
        case smellLevelCode = "smellValue"
        case smellLevelName = "smellValueName"
        case smellTypeCode = "smellType"
        case smellTypeName = "smellTypeName"
        
        case weatherStateCode = "weatherState"
        case weatherState = "weatherStateName"
        case temperature = "temperatureValue"
        case humidity = "humidityValue"
        case windDirectionCode = "windDirectionValue"
        case windDirection = "windDirectionValueName"
        case windSpeed = "windSpeedValue"
        
        case longitude = "gpsX"
        case latitude = "gpsY"
        case comment = "smellComment"
    }
}

//MARK: - 접수 이력 상세 정보(첨부사진 이미지)
struct DetailHistory: Codable {
    let registNo: String    //접수 등록번호
    let registDate: String  //접수 등록일시
    let imageNo: String //이미지 번호
    let imagePath: String   //이미지 URL 경로
    
    enum CodingKeys: String, CodingKey {
        case registNo = "smellRegisterNo"
        case registDate = "regDt"
        case imageNo = "smellImageNo"
        case imagePath = "smellImagePath"
    }
}
