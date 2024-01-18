//
//  SignInViewModel.swift
//  IoTBadSmellMonitoring
//
//  Created by KJ on 2021/06/03.
//

import Foundation
import Alamofire
import Combine

class SignInViewModel: ObservableObject {
    private let userAPI = UserAPIService()  //사용자 API Service
    
    @Published var result: String = ""   //결과 상태
    @Published var message: String = "" //결과 메시지
    @Published var validMessage: String = ""    //유효성 검사 메시지
    
    @Published var id: String = ""   //ID
    @Published var password: String = ""    //비밀번호
    
    //MARK: - 자동 로그인
    func authSignIn(completion: @escaping (String) -> Void) {
        
        //API 호출 - Request Body
        let parameters = [
            "userId": UserDefaults.standard.string(forKey: "userId") ?? "null",
            "userPassword": UserDefaults.standard.string(forKey: "password") ?? "null"
        ]
        
        //로그인 API 호출
        let request = userAPI.requestSignIn(parameters: parameters)
        request.execute(
            //API 호출 성공
            onSuccess: { (signIn) in
                //로그인 성공
                if signIn.result == "success" {
                    self.result = signIn.result
                    
                    UserDefaults.standard.set(signIn.data?.userName, forKey: "userName")    //사용자 명 저장
                    
                    UserDefaults.standard.set(signIn.data?.topRegionCode, forKey: "topRegionCode")  //상위 지역 코드
                    UserDefaults.standard.set(signIn.data?.topRegionName, forKey: "topRegionName")  //상위 지역 명
                    UserDefaults.standard.set(signIn.data?.subRegionCode, forKey: "subRegionCode")  //하위 지역 코드
                    UserDefaults.standard.set(signIn.data?.subRegionName, forKey: "subRegionName")  //하위 지역 명
                    UserDefaults.standard.set(true, forKey: "isSignIn")                             //로그인 여부
                }
                //로그인 실패
                else {
                    //사용자 정보 전체 삭제
                    for key in UserDefaults.standard.dictionaryRepresentation().keys {
                        UserDefaults.standard.removeObject(forKey: key.description)
                    }
                    if signIn.result == "statusNotChange" {
                        self.result = signIn.result
                        self.message = "관리자 승인이 필요한 회원입니다."
                    } else {
                        self.result = signIn.result
                        self.message = "아이디 또는 비밀번호가 일치하지 않습니다."
                    }
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
                    
                    UserDefaults.standard.set(signIn.data?.topRegionCode, forKey: "topRegionCode")  //상위 지역 코드
                    UserDefaults.standard.set(signIn.data?.topRegionName, forKey: "topRegionName")  //상위 지역 명
                    UserDefaults.standard.set(signIn.data?.subRegionCode, forKey: "subRegionCode")  //하위 지역 코드
                    UserDefaults.standard.set(signIn.data?.subRegionName, forKey: "subRegionName")  //하위 지역 명
                    UserDefaults.standard.set(true, forKey: "isSignIn")                             //로그인 여부
                }
                //로그인 실패
                else {
                    if signIn.result == "statusNotChange" {
                        self.result = signIn.result
                        self.message = "관리자 승인이 필요한 회원입니다."
                    } else {
                        self.result = signIn.result
                        self.message = "아이디 또는 비밀번호가 일치하지 않습니다."
                    }
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
        let regExp = "^[a-zA-Z0-9]{4,20}$" //영문, 숫자
        let idPredicate = NSPredicate(format: "SELF MATCHES %@", regExp)
        
        return idPredicate.evaluate(with: id)
    }
    
    //MARK: - 비밀번호 유효성 검사
    func isPasswordValid() -> Bool {
        let regExp = "^[a-zA-Z0-9~!@#\\$%\\^&\\*]{4,15}$"   //영문, 숫자, 특수문자
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", regExp)
        
        return passwordPredicate.evaluate(with: password)
    }
    
    //MARK: - 비밀번호 찾기
    func findPassword() -> String {
        self.message = "관리자에게 문의 바랍니다."
        
        return message
    }
}
