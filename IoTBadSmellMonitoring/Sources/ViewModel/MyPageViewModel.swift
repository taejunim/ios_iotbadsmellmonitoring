//
//  MyPageViewModel.swift
//  IoTBadSmellMonitoring
//
//  Created by guava on 2021/06/24.
//

import Foundation

class MyPageViewModel: ObservableObject {
    private let userAPI = UserAPIService()  //사용자 API Service
    
    @Published var result: String = ""   //결과 상태
    @Published var message: String = "" //결과 메시지
    @Published var validMessage: String = ""    //유효성 검사 메시지
    
    @Published var currentPassword: String = ""   //현재 비밀번호
    @Published var newpassword: String = ""    //새 비밀번호
    @Published var confirmPassword: String = ""    //비밀번호 확인
    
    //MARK: - 로그인 실행(로그인 API 호출)
    /// 로그인 API 호출을 통한 현재 비밀번호 일치 여부 확인
    /// - Parameter completion: 로그인 결과
    func signIn(completion: @escaping (String) -> Void) {
        
        //API 호출 - Request Body
        let parameters = [
            "userId": "test123",
            "userPassword": "test123"
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
                print(signIn)
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
    // 비밀번호 수정  API 호출을 통한 비밀번호 수정 실행
    // - Parameter completion: 비밀번호 수정 결과
    func passwordChange(completion: @escaping (String) -> Void) {
        
        //API 호출 - Request Body
        let parameters = [
            "userId": "test123",
            "userPassword": "test123"
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
                print(passwordChange)
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
        if newpassword != confirmPassword {
            confirmPassword = ""
            self.validMessage = "비밀번호가 일치하지 않습니다."
            
            return false
        }
        return true
    }
    //MARK: - 새 비밀번호 유효성 검사
    func isPasswordValid() -> Bool {
        let regExp = "^[a-zA-Z0-9]{5,15}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", regExp)
        
        return passwordPredicate.evaluate(with: newpassword)
    }
    //MARK: - 입력 완료 여부
    var isInputComplete: Bool {
        if currentPassword.isEmpty || newpassword.isEmpty || confirmPassword.isEmpty {
            return false
        }
        else {
            return true
        }
    }
}
