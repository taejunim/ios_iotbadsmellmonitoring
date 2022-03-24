//
//  CodeModel.swift
//  IoTBadSmellMonitoring
//
//  Created by KJ on 2021/06/14.
//

import Foundation

//MARK: - 코드 데이터 정보
struct Code: Codable {
    let codeGroup: String   //코드 그룹
    let codeGroupName: String   //코드 그룹 명
    let codeId: String  //코드 ID
    let codeIdName: String  //코드 ID 명
    let codeComment: String //코드 설명
}

//MARK: - 현재 시간 정보
struct CurrentDate: Codable {
    let result: String  //결과
    let data: String?   //데이터
}

//MARK: - 지역 정보 목록
struct Regions: Codable {
    let region: Region  //지역 정보
}

//MARK: - 지역 정보
struct Region: Codable {
    let topRegion: [TopRegion]  //상위 지역 정보 목록
    
    enum CodingKeys: String, CodingKey {
        case topRegion = "master"
    }
}

//MARK: - 상위 지역 정보
struct TopRegion: Codable {
    let code: String    //상위 지역 코드
    let codeName: String    //상위 지역 코드명
    let subRegion: [SubRegion]  //하위 지역 정보 목록
    
    enum CodingKeys: String, CodingKey {
        case code = "mCodeId"
        case codeName = "mCodeIdName"
        case subRegion = "detail"
    }
}

//MARK: - 하위 지역 정보
struct SubRegion: Codable {
    let code: String    //하위 지역 코드
    let codeName: String    //하위 지역 코드명
    
    enum CodingKeys: String, CodingKey {
        case code = "dCodeId"
        case codeName = "dCodeIdName"
    }
}
