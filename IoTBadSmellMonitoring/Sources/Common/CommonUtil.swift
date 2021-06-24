//
//  CommonUtil.swift
//  IoTBadSmellMonitoring
//
//  Created by KJ on 2021/06/22.
//

import Foundation

extension String {
    //MARK: - Date(일자) 포맷
    /// 일자 포맷팅 함수 - 사용 방법 : "yyyymmdd".dateFormatter(Date())
    /// - Parameter formatDate: 포맷팅 형식 - ex) "yyyymmdd", "HH : mm : ss"
    /// - Returns: 포맷팅된 Date
    func dateFormatter(formatDate: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = self
        
        return dateFormatter.string(from: formatDate)
    }
}
