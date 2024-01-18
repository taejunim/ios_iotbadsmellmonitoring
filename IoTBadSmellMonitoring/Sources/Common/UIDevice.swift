//
//  UIDevice.swift
//  IoTBadSmellMonitoring
//
//  Created by 김우성 on 2023/12/27.
//

import Foundation
import UIKit

extension UIDevice {
    static func isiPhoneSE() -> Bool {
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone && (UIScreen.main.bounds.size.height <= 667 || UIScreen.main.bounds.size.width <= 375) {
            return true
        }
        return false
    }
}
