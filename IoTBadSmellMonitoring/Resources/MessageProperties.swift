//
//  MessageProperties.swift
//  IoTBadSmellMonitoring
//
//  Created by KJ on 2021/06/16.
//

import Foundation

enum Message {
    enum Server: String {
        case error = "error"
    }
    
    enum SignIn {
        case success
        case fail
        case error
    }
}
