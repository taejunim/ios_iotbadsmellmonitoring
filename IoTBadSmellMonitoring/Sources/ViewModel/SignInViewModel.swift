//
//  SignInViewModel.swift
//  IoTBadSmellMonitoring
//
//  Created by KJ on 2021/06/03.
//

import Foundation
import Alamofire

class SignInViewModel: ObservableObject {
    private let userAPI = UserAPIService()  //사용자 API Service
    
    @Published var result: String = ""   //결과 상태
    @Published var message: String = "" //결과 메시지
    @Published var validMessage: String = ""    //유효성 검사 메시지
    
    @Published var id: String = ""   //ID
    @Published var password: String = ""    //비밀번호
    
    //MARK: - 로그인 실행(로그인 API 호출)
    /// 로그인 API 호출을 통한 로그인 실행
    /// - Parameter completion: 로그인 결과
    func signIn(completion: @escaping (String) -> Void) {
        
        //API 호출 - Request Body
        let parameters = [
            "userId": id,
            "userPassword": password
        ]
        
        //로그인 API 호출
        let request = userAPI.requestSignIn(parameters: parameters)
        request.execute(
            //API 호출 성공
            onSuccess: { (signIn) in
                //로그인 성공
                if signIn.result == "success" {
                    self.result = signIn.result
                    
                    UserDefaults.standard.set(signIn.data?.id, forKey: "userId")    //사용자 ID 저장
                    UserDefaults.standard.set(self.password, forKey: "password")    //패스워드 저장
                    UserDefaults.standard.set(signIn.data?.userName, forKey: "userName")    //사용자 명 저장
                }
                //로그인 실패
                else {
                    self.result = signIn.result
                    self.message = "아이디 또는 비밀번호가 일치하지 않습니다."
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
        //ID 입력 여부 확인
        if id.isEmpty {
            self.validMessage = "아이디를 입력하세요."
            return false
        }
        else {
            guard isIdValid() else {
                self.validMessage = "올바른 아이디를 입력하세요."
                return false
            }
        }
        
        //비밀번호 입력 여부 확인
        if password.isEmpty {
            self.validMessage = "비밀번호를 입력하세요."
            return false
        }
        else {
            guard isPasswordValid() else {
                self.validMessage = "올바른 비밀번호를 입력하세요."
                return false
            }
        }
        
        return true
    }
    
    //MARK: - ID 유효성 검사
    func isIdValid() -> Bool {
        let regExp = "^[a-zA-Z0-9]{5,20}$"
        let idPredicate = NSPredicate(format: "SELF MATCHES %@", regExp)
        
        return idPredicate.evaluate(with: id)
    }
    
    //MARK: - 비밀번호 유효성 검사
    func isPasswordValid() -> Bool {
        let regExp = "^[a-zA-Z0-9]{5,15}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", regExp)
        
        return passwordPredicate.evaluate(with: password)
    }
    
    //MARK: - 비밀번호 찾기
    func findPassword() -> String {
        self.message = "관리자에게 문의 바랍니다."
        
        return message
    }
}
