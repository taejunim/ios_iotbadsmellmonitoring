//
//  UserModel.swift
//  IoTBadSmellMonitoring
//
//  Created by KJ on 2021/06/03.
//

import Foundation

//MARK: - 사용자 정보
struct User: Codable {
    let id: String  //아이디
    let userType: String    //사용자 타입
    let userTypeName: String    //사용자 타입 명
    let userName: String    //사용자 명
    let phoneNumber: String //휴대전화번호
    let age: String //나이
    let sexCode: String //성별 코드
    let sexName: String //성별 명
    let topRegionCode: String   //상위 지역 코드
    let topRegionName: String   //상위 지역 명
    let subRegionCode: String   //하위 지역 코드
    let subRegionName: String   //하위 지역 명
    
    //Response JSON Key와 변수명 매칭
    enum CodingKeys: String, CodingKey {
        case id = "userId"
        case userType
        case userTypeName
        case userName
        case phoneNumber = "userPhone"
        case age = "userAge"
        case sexCode = "userSex"
        case sexName = "userSexName"
        case topRegionCode = "userRegionMaster"
        case topRegionName = "userRegionMasterName"
        case subRegionCode = "userRegionDetail"
        case subRegionName = "userRegionDetailName"
    }
}

//MARK: - 인증 번호
struct AuthNumber: Codable {
    let authNumber: String
    
    enum CodingKeys: String, CodingKey {
        case authNumber = "authNum"
    }
}
