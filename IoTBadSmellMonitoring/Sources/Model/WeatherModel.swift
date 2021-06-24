//
//  WeatherModel.swift
//  IoTBadSmellMonitoring
//
//  Created by KJ on 2021/06/03.
//

import Foundation

//MARK: - 날씨 정보
struct Weather: Codable {
    let response: WeatherResponse   //날씨 정보 Response
}

//MARK: - 날씨 정보 Response
struct WeatherResponse: Codable {
    let header: WeatherHeader   //날씨 정보 Header
    let body: WeatherBody?   //날씨 정보 Body
}

//MARK: - 날씨 정보 Header
struct WeatherHeader: Codable {
    let resultCode: String  //결과 코드
    let resultMsg: String   //결과 메시지
}

//MARK: - 날씨 정보 Body
struct WeatherBody: Codable {
    let dataType: String    //데이터 타입
    let items: WeatherItems  //날씨 정보 Items
    let pageNo: Int //페이지 번호
    let numOfRows: Int  //한 페이지 결과 수
    let totalCount: Int //전체 결과 수
}

//MARK: - 날씨 정보 Items
struct WeatherItems: Codable {
    let item: [WeatherItem] //날씨 정보 Item
}

//MARK: - 날씨 정보 Item
struct WeatherItem: Codable {
    let baseDate: String    //발표일자
    let baseTime: String    //발표시각
    let category: String    //자료구분 코드
    let fcstDate: String    //예측일자
    let fcstTime: String    //예측시간
    let fcstValue: String   //예보 값
    let nx: Int //예보지점 X 좌표
    let ny: Int //예보지점 Y 좌표
}
