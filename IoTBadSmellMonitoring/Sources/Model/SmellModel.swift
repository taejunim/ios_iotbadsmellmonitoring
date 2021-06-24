//
//  SmellModel.swift
//  IoTBadSmellMonitoring
//
//  Created by KJ on 2021/06/21.
//

import Foundation

//MARK: - 금일 접수 현황 정보
struct TodayReception: Codable {
    let timeZoneCode: String
    let timeZone: String
    let status: String
    let receptionDate: String
    
    //Response JSON Key와 변수명 매칭
    enum CodingKeys: String, CodingKey {
        case timeZoneCode = "smellRegisterTime"
        case timeZone = "smellRegisterTimeName"
        case status = "resultCode"
        case receptionDate = "regDt"
    }
}
