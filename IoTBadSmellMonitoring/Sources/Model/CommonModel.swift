//
//  CommonModel.swift
//  IoTBadSmellMonitoring
//
//  Created by KJ on 2022/03/16.
//

import Foundation

//MARK: - 공지사항 정보
struct Notice: Codable {
    let noticeTitle: String //공지사항 제목
    let noticeContents: String  //공지사항 내용
}

//MARK: - 사용자 격자 정보
struct GridCoordinates: Codable {
    let gridX: String   //격자 X
    let gridY: String   //격자 Y
    
    enum CodingKeys: String, CodingKey {
        case gridX = "addressX"
        case gridY = "addressY"
    }
}
