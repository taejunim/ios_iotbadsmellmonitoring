//
//  KeyboardUtil.swift
//  IoTBadSmellMonitoring
//
//  Created by KJ on 2021/07/21.
//

import SwiftUI
import Foundation

class KeyboardUtil: ObservableObject {
    
    private var _center: NotificationCenter
    @Published var currentHeight: CGFloat = 0
    
    init(center: NotificationCenter = .default) {
        _center = center
        _center.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        _center.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        _center.removeObserver(self)
    }
    
    //키보드 활성화 시, 키보드 높이만큼 화면 이동
    @objc func keyBoardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            currentHeight = keyboardSize.height
        }
    }
    
    //키보드 비활성화 시, 이동된 화면 복구
    @objc func keyBoardWillHide(notification: Notification) {
        currentHeight = 0
    }
}
