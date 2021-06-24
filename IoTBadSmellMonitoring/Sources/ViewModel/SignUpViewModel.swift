//
//  SignUpViewModel.swift
//  IoTBadSmellMonitoring
//
//  Created by KJ on 2021/06/03.
//

import Foundation
import SwiftUI

class SignUpViewModel: ObservableObject {
    private let codeViewModel = CodeViewModel() //Code View Model
    private let userAPI = UserAPIService()  //사용자 API Service
    
    @Published var sexCode: [[String: String]] = [[:]]  //성별 코드
    @Published var regionCode: [[String: String]] = [[:]]  //지역 코드
    
    @Published var result: String = ""   //결과 상태
    @Published var message: String = "" //결과 메시지
    @Published var validMessage: String = ""    //유효성 검사 메시지
    
    @Published var userType: String = "001"    //사용자 타입 - 일반 사용자(001)
    @Published var id: String = ""   //사용자 ID
    @Published var password: String = ""    //비밀번호
    @Published var confirmPassword: String = "" //비밀번호 확인
    @Published var name: String = ""    //이름
    @Published var age: String = "0" //나이
    @Published var selectSex: String = "001"    //성별 선택
    @Published var selectRegion: String = "001" //지역 선택
    
    @Published var isCheckId: Bool = false  //ID 중복확인 여부
    @Published var confirmId: String = ""   //중복확인 완료 ID
    
    //MARK: - 성별 코드 API 호출
    func getSexCode() {
        codeViewModel.getCode(codeGroup: "SEX") { (code) in
            self.sexCode = code
        }
    }
    
    //MARK: - 지역 코드 API 호출
    func getRegionCode() {
        codeViewModel.getCode(codeGroup: "RGN") { (code) in
            self.regionCode = code
        }
    }
    
    //MARK: - ID 중복확인
    /// ID 중복확인  API를 통해 ID 중복확인
    /// - Parameter completion: ID 중복확인 결과
    func checkId(completion: @escaping (String) -> Void) {
        isCheckId = false   //ID 중복확인 여부 초기화
        confirmId = "" //중복확인 완료 ID 초기화
        
        //중복 확인할 ID 유효성 검사
        guard isIdValid() else {
            self.result = "valid error"
            self.validMessage = "형식에 맞지 않는 아이디입니다."
            completion(self.result)
            
            return
        }
        
        //API 호출 - Request Parameters
        let parameters = [
            "userId": id
        ]
        
        //ID 찾기 API 호출
        let request = userAPI.requestFindId(parameters: parameters)
        request.execute(
            //API 호출 성공
            onSuccess: { (checkId) in
                print(checkId)
                if checkId.result == "success" {
                    self.result = checkId.result
                    self.message = "이미 사용중인 아이디입니다."
                }
                else {
                    self.isCheckId = true   //ID 중복확인 여부 - 확인완료 상태
                    self.confirmId = self.id    //중복확인 완료 ID - 입력한 ID
                    self.result = checkId.result
                    self.message = "등록 가능한 아이디입니다."
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
    
    //MARK: - 회원가입 실행
    /// 회원가입 API를 통한 회원가입 실행
    /// - Parameter completion: 회원가입 결과
    func signUp(completion: @escaping (String) -> Void) {
        //API 호출 - Request Body
        let parameters = [
            "userType": userType,
            "userId": confirmId,
            "userPassword": password,
            "userName": name,
            "userAge": String(age),
            "userSex": selectSex,
            "userRegion": selectRegion
        ]

        //회원가입 API 호출
        let request = userAPI.requestSignUp(parameters: parameters)
        request.execute(
            //API 호출 성공
            onSuccess: { (signUp) in
                print(signUp)
                //회원가입 성공
                if signUp.result == "success" {
                    self.result = signUp.result
                    self.message = "회원가입이 완료되었습니다."
                }
                //회원가입 실패
                else {
                    self.result = signUp.result
                    self.message = "회원가입에 실패하였습니다."
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
            self.validMessage = "아이디를 입력하지 않았습니다."
            return false
        }
        else {
            guard isIdValid() else {
                self.validMessage = "형식에 맞지않는 아이디입니다."
                return false
            }
        }
        
        //ID 중복확인 여부 확인
        if !isCheckId {
            self.validMessage = "아이디 중복 확인을 하지 않았습니다."
            return false
        }

        //비밀번호 입력 여부 확인
        if password.isEmpty {
            self.validMessage = "비밀번호를 입력하지 않았습니다."
            return false
        }
        else {
            guard isPasswordValid() else {
                self.validMessage = "형식에 맞지않는 비밀번호입니다."
                return false
            }
        }

        //비밀번호 확인 입력 여부 확인
        if confirmPassword.isEmpty {
            self.validMessage = "비밀번호 확인을 입력하지 않았습니다."
            return false
        }
        else {
            guard isConfirmPasswordValid() else {
                self.validMessage = "형식에 맞지않는 비밀번호입니다."
                return false
            }
        }
        
        //입력한 비밀번호 일치 여부 확인
        if password != confirmPassword {
            confirmPassword = ""
            self.validMessage = "비밀번호가 일치하지 않습니다."
            
            return false
        }
        
        //이름 입력 여부 확인
        if name.isEmpty {
            self.validMessage = "이름을 입력하지 않았습니다."
            return false
        }
        else {
            guard isNameValid() else {
                self.validMessage = "이름은 한글만 입력 가능합니다."
                return false
            }
        }
        
        let filterAge = age.filter {$0.isNumber}    //압력 나이 숫자만 필터
        age = filterAge //필터된 숫자
        
        //나이 입력 여부 확인
        if age.isEmpty || Int(age)! <= 0 {
            self.validMessage = "나이를 입력하지 않았거나 0보다 큰 숫자를 입력하세요."
            return false
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
    
    //MARK: - 비밀번호 확인 유효성 검사
    func isConfirmPasswordValid() -> Bool {
        let regExp = "^[a-zA-Z0-9]{5,15}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", regExp)
        
        return passwordPredicate.evaluate(with: confirmPassword)
    }
    
    //MARK: - 이름 유효성 검사
    func isNameValid() -> Bool {
        let regExp = "^[가-힣ㄱ-ㅎㅏ-ㅣ]{2,10}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", regExp)
        
        return passwordPredicate.evaluate(with: name)
    }
    
    //MARK: - 입력 완료 여부
    var isInputComplete: Bool {
        if id.isEmpty || password.isEmpty || confirmPassword.isEmpty || name.isEmpty || age.isEmpty {
            return false
        }
        else {
            return true
        }
    }
}
