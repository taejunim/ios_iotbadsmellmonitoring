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
