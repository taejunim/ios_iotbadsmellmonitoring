//
//  SideMenuViewModel.swift
//  IoTBadSmellMonitoring
//
//  Created by KJ on 2021/07/12.
//

import SwiftUI
import Foundation

class SideMenuViewModel: ObservableObject {
    private let viewUtil = ViewUtil()
    @Published var showAlert: Bool = false
    @Published var alert: Alert?    //알림창
    @Published var isSignOut: Bool = false
    
    func signOutAlert() -> Alert {
        return Alert(
            title: Text("로그아웃"),
            message: Text("로그아웃 하시겠습니까?"),
            primaryButton: .destructive(
                Text("확인"),
                action: {
                    print("Side Model: \(self.isSignOut)")
                    self.signOut()
                    print("Side Model: \(self.isSignOut)")
                }
            ),
            secondaryButton: .cancel(
                Text("닫기"),
                action: {
                    //self.viewUtil.showAlert = false
                }
            )
        )
    }
    
    func signOut() {
        //UserDefaults 값 초기화
        for key in UserDefaults.standard.dictionaryRepresentation().keys {
            UserDefaults.standard.removeObject(forKey: key.description)
        }
        //viewUtil.showMenu = false
        self.isSignOut = true
    }
}
