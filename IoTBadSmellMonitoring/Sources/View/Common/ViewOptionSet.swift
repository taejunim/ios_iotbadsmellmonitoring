//
//  ViewOptionSet.swift
//  IoTBadSmellMonitoring
//
//  Created by KJ on 2021/06/14.
//

import SwiftUI
import Foundation
    
class ViewOptionSet: ObservableObject {
    
    init() {
        self.navigationBarOption()
        self.pickerOption()
    }
    
    //MARK: - Navigation Bar Option
    /// Navigation Bar 옵션 설정
    func navigationBarOption() {
        UINavigationBar.appearance().barTintColor = UIColor.white   //Navigation Bar 배경 색상
        //UINavigationBar.appearance().isTranslucent = false
    }
    
    //MARK: - Picker Option
    /// Picker 옵션 설정
    func pickerOption() {
        //Picker - 선택된 Selection 색상 변경
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white
        ]
    
        UISegmentedControl.appearance().setTitleTextAttributes(attributes, for: .selected)  //Text 색상
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(named: "Color_3498DB")   //배경 색상
    }
}
