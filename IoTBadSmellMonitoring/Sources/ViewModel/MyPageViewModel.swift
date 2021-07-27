//
//  MyPageViewModel.swift
//  IoTBadSmellMonitoring
//
//  Created by guava on 2021/06/24.
//

import SwiftUI
import UIKit
import Foundation
import UserNotifications

class MyPageViewModel: ObservableObject {
    private let codeViewModel = CodeViewModel() //Code View Model
    private let userAPI = UserAPIService()  //사용자 API Service
    
    @Published var result: String = ""   //결과 상태
    @Published var message: String = "" //결과 메시지
    @Published var validMessage: String = ""    //유효성 검사 메시지
    
    @Published var currentPassword: String = ""   //현재 비밀번호
    @Published var newPassword: String = ""    //새 비밀번호
    @Published var confirmPassword: String = ""    //비밀번호 확인
    @Published var showToggle: Bool = false //토글 상태
    
    init() {
        //알림 허용 권한 상태 확인
        self.checkAuthStatus() { status in
            UserDefaults.standard.set(status, forKey: "notificationAuth") //알림 권한
            
            //알림 권한이 없는 경우 알림 허용 요청
            if !status {
                self.requestAuthorization() //알림 허용 요청
            }
        }
    }
    
    //MARK: - 사용자 확인 (푸시 알림 허가 받기)
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization (
            options: [.alert,.sound,.badge], completionHandler: { didAllow, Error in
                
                UserDefaults.standard.set(didAllow, forKey: "notificationAuth") //알림 권한
                UserDefaults.standard.set(didAllow, forKey: "notificationStatus")   //알림 상태
                
                //알림 상태 true인 경우
                if didAllow {
                    self.scheduleNotification() //푸시 알림 실행
                }
            }
        )
    }
    
    //MARK: - 알림 권한 상태 확인
    func checkAuthStatus(completion: @escaping (Bool) -> Void) {
        let notificationCurrent = UNUserNotificationCenter.current()
        
        notificationCurrent.getNotificationSettings(completionHandler: { (setting) in
            var isAuthStatus = false    //권한 허용 여부
            
            let status = setting.authorizationStatus    //알림 권한 상태
            
            //알림 여부 미 선택
            if status == .notDetermined {
                isAuthStatus = false
            }
            //알림 권한 없음
            else if status == .denied {
                isAuthStatus = false
            }
            //알림 권한 있음
            else if status == .authorized {
                isAuthStatus = true
            }
            //알림 임시 권한
            else if status == .provisional {
                isAuthStatus = true
            }
            //알림 수신 권한
            else if status == .ephemeral {
                isAuthStatus = true
            }
            
            completion(isAuthStatus)
        })
    }
    
    //MARK: - 푸시 알림 설정 및 실행
    func scheduleNotification() {
        
        self.removeNotification()   //기존 푸시 알림 설정 삭제
        
        //사용자 확인 완료 시 시간 알림 수행
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { (success, error) in
            if let error = error {           //에러
                print("ERROR: \(error)")
            }
            else {                          //성공 시 수행
                //API codeComment 가져오기
                self.codeViewModel.getCode(codeGroup: "REN") { (code) in
                    
                    UIApplication.shared.applicationIconBadgeNumber = 0
                    
                    // 푸시 알림 내용
                    let content = UNMutableNotificationContent()
                    let badgeCount = 1 + UIApplication.shared.applicationIconBadgeNumber as NSNumber

                    content.title = "악취 접수 알림"                  //제목	
                    content.body = "근처에서 악취가 난다면 접수 해주세요!"     //내용
                    content.sound = .default
                    content.badge = badgeCount  //Badge 표시 - 알림 올 경우, 앱 아이콘 숫자 표시
                    
                    //푸시 알림 시간
                    var dateComponents = DateComponents()
                    for i in 0...code.count-1 {     //0부터 3까지 4번 수행
                        
                        let time = code[i]["codeComment"]!  //codeComment 받아오기
                        let pushHour = time.prefix(2)           //시 변수 선언 (codeComment 앞 두자리)
                        let pushMinute = time.suffix(2)         //분 변수 선언 (codeComment 뒤 두자리)
                        
                        dateComponents.hour = Int(pushHour)!        //알림 시 INT형으로
                        dateComponents.minute = Int(pushMinute)!    //알림 분 INT형으로
                        
                        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                        
                        UNUserNotificationCenter.current().add(request)
                    }
                }
            }
        }
    }
    
    //MARK: - 알림 설정 삭제
    func removeNotification() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()   //저장된 알림 설정 전체 삭제
    }
    
    //MARK: - 알림 설정 창 이동 알림창
    func requestAuthAlert() -> Alert {
        return Alert(
            title: Text("알림 허용"),
            message: Text("악취 접수 알림을 위해서는 알림 허용이 필요합니다."),
            primaryButton: .destructive(
                Text("설정"),
                action: {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)    //앱 설정 화면으로 이동
                }
            ),
            secondaryButton: .cancel(
                Text("닫기"),
                action: {
                    self.showToggle = false
                }
            )
        )
    }
    
    //MARK: - 로그인 실행(로그인 API 호출)
    /// 로그인 API 호출을 통한 현재 비밀번호 일치 여부 확인
    /// - Parameter completion: 로그인 결과
    func signIn(completion: @escaping (String) -> Void) {
        
        //API 호출 - Request Body
        let parameters = [
            "userId": UserDefaults.standard.string(forKey: "userId")!,  //사용자 기본값에 저장된 사용자 ID
            "userPassword": self.currentPassword    //현재 비밀번호
        ]
        
        //로그인 API 호출
        let request = userAPI.requestSignIn(parameters: parameters)
        request.execute(
            //API 호출 성공
            onSuccess: { (signIn) in
                //로그인 성공
                if signIn.result == "success" {
                    self.result = signIn.result
                }
                //로그인 실패
                else {
                    self.result = signIn.result
                    self.message = "현재 비밀번호가 일치하지 않습니다."
                }
                
                completion(self.result)
            },
            //API 호출 실패
            onFailure: { (error) in
                self.result = "server error"
                self.message = "서버와의 통신이 원활하지 않습니다."
                
                completion(self.result)
                
                print(error.localizedDescription)
            }
        )
    }
    
    //MARK: - 비밀번호 수정 실행(비밀번호 수정 API 호출)
    /// 비밀번호 수정  API 호출을 통한 비밀번호 수정 실행
    /// - Parameter completion: 비밀번호 수정 결과
    func passwordChange(completion: @escaping (String) -> Void) {
        
        //API 호출 - Request Body
        let parameters = [
            "userId": UserDefaults.standard.string(forKey: "userId")!,
            "userPassword": self.newPassword
        ]
        
        //비밀번호 수정 API 호출
        let request = userAPI.requestPasswordChange(parameters: parameters)
        request.execute(
            //API 호출 성공
            onSuccess: { (passwordChange) in
                //비밀번호 수정 성공
                if passwordChange.result == "success" {
                    self.result = passwordChange.result
                    self.message = "비밀번호가 수정되었습니다."
                }
                //비밀번호 수정 실패
                else {
                    self.result = passwordChange.result
                    self.message = "비밀번호 수정에 실패하였습니다."
                }
                
                completion(self.result)
            },
            //API 호출 실패
            onFailure: { (error) in
                self.result = "server error"
                self.message = "서버와의 통신이 원활하지 않습니다."
                
                completion(self.result)
                
                print(error.localizedDescription)
            }
        )
    }
    
    //MARK: - 유효성 검사
    func validate() -> Bool {
        
        //새 비밀번호 형식 확인
        guard isPasswordValid() else {
            self.validMessage = "새 비밀번호를 형식에 맞게 입력하세요."
            return false
        }
        
        //입력한 비밀번호 일치 여부 확인
        if newPassword != confirmPassword {
            currentPassword = ""
            newPassword = ""
            confirmPassword = ""
            self.validMessage = "새 비밀번호가 일치하지 않습니다."
            
            return false
        }
        
        return true
    }
    
    //MARK: - 새 비밀번호 유효성 검사
    func isPasswordValid() -> Bool {
        let regExp = "^[a-zA-Z0-9]{5,15}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", regExp)
        
        return passwordPredicate.evaluate(with: newPassword)
    }
    
    //MARK: - 입력 완료 여부
    var isInputComplete: Bool {
        if currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty {
            return false
        }
        else {
            return true
        }
    }
}
