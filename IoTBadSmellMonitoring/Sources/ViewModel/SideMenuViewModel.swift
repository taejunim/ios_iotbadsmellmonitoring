//
//  SideMenuViewModel.swift
//  IoTBadSmellMonitoring
//
//  Created by KJ on 2021/07/12.
//

import SwiftUI
import Foundation

class SideMenuViewModel: ObservableObject {
    @Published var showAlert: Bool = false  //알림창 노출 여부
    @Published var alert: Alert?    //알림창
    @Published var isSignOut: Bool = false  //로그아웃 여부
    @Published var moveMenu: String = ""    //이동할 메뉴
    
    //MARK: - 로그아웃 확인 알림창
    func signOutAlert() -> Alert {
        return Alert(
            title: Text("로그아웃"),
            message: Text("로그아웃 하시겠습니까?"),
            primaryButton: .destructive(
                Text("확인"),
                action: {
                    self.signOut()  //로그아웃 실행
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
    
    //MARK: - 로그아웃 실행
    func signOut() {
        print("들어온다")
        //UserDefaults 값 초기화
        for key in UserDefaults.standard.dictionaryRepresentation().keys {
            UserDefaults.standard.removeObject(forKey: key.description)
        }
        
        self.isSignOut = true   //로그아웃 처리
    }
}
