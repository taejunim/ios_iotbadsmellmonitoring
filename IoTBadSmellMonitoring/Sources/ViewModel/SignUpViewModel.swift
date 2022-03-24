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
    
    @Published var isCheckPrivacy: Bool = false //개인정보 처리방침 체크버튼 체크 여부
    @Published var isPrivacyAgree: Bool = false //개인정보 처리방침 동의 여부
    
    @Published var sexCode: [[String: String]] = [[:]]  //성별 코드
    @Published var regionCode: [[String: String]] = [[:]]  //지역 코드
    
    @Published var topRegionCode: [[String : String]] = []  //상위 지역 코드 목록
    @Published var fullSubRegionCode: [[String : String]] = []  //전체 하위 지역 코드 목록
    @Published var subRegionCode: [[String : String]] = []  //상위 지역에 해당하는 하위 지역 코드 목록
    
    @Published var userType: String = "001"    //사용자 타입 - 일반 사용자(001)
    @Published var id: String = ""   //사용자 ID
    @Published var password: String = ""    //비밀번호
    @Published var confirmPassword: String = "" //비밀번호 확인
    @Published var name: String = ""    //이름
    @Published var phoneNumber: String = ""  //휴대전화번호
    //휴대전화번호 - 통신망 식별 번호
    @Published var networkIDNumber: String = "" {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                while self.networkIDNumber.count > 3 {
                    self.networkIDNumber.removeLast()
                    //self.focusPhoneNumberField = .stationNumber
                }
            }
        }
    }
    //휴대전화번호 - 국 번호
    @Published var stationNumber: String = "" {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                while self.stationNumber.count > 4 {
                    self.stationNumber.removeLast()
                }
            }
        }
    }
    //휴대전화번호 - 가입자 개별 번호
    @Published var individualNumber: String = "" {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                while self.individualNumber.count > 4 {
                    self.individualNumber.removeLast()
                }
            }
        }
    }
    @Published var authNumber: String = ""  //인증번호
    //나이
    @Published var age: String = "" {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                while self.individualNumber.count > 3 {
                    self.individualNumber.removeLast()
                }
            }
        }
    }
    @Published var selectSex: String = "000"    //성별 선택
    @Published var selectTopRegion: String = "000" //상위 지역 선택
    @Published var selectSubRegion: String = "000"  //하위 지역 선택
    
    @Published var isCheckId: Bool = false  //ID 중복확인 여부
    @Published var confirmId: String = ""   //중복확인 완료 ID
    
    @Published var isAuthRequest: Bool = false //인증 요청 여부
    @Published var isAuthComplete: Bool = false //인증 완료 여부
    @Published var receivedAuthNumber: String = ""  //API 호출 인증번호
    @Published var confirmPhoneNumber: String = "" //
    
    @Published var result: String = ""   //결과 상태
    @Published var message: String = "" //결과 메시지
    @Published var validMessage: String = ""    //유효성 검사 메시지
    
    //MARK: - 회원가입 화면 초기화
    func initSignUpView() {
        isCheckPrivacy = false
        
        id = ""
        password = ""
        confirmPassword = ""
        name = ""
        networkIDNumber = ""
        stationNumber = ""
        individualNumber = ""
        authNumber = ""
        age = ""
        selectSex = "000"
        selectTopRegion = "000"
        selectSubRegion = "000"
        
        isCheckId = false
        confirmId = ""
        
        isAuthRequest = false
        isAuthComplete = false
        receivedAuthNumber = ""
    }
    
    //MARK: - 성별 코드 API 호출
    func getSexCode() {
        codeViewModel.getCode(codeGroup: "SEX") { (code) in
            self.sexCode = code
        }
    }
    
    //MARK: - 지역 코드 API 호출
    func getRegionCode() {
        codeViewModel.getRegion() { (topRegions, subRegions) in
            self.topRegionCode = topRegions
            self.fullSubRegionCode = subRegions
        }
    }
    
    //MARK: - 상위 지역 선택 시, 하위 지역 Picker 변경
    /// - Parameter selectTopRegion: 선택한 상위 지역 코드
    func changeSubRegionPicker(selectTopRegion: String) {
        selectSubRegion = "000" //하위 지역 선택 초기화
        subRegionCode.removeAll()   //기존 하위 지역 코드 목록 초기화
        
        for getSubRegionCode in fullSubRegionCode {
            //선택한 상위 지역에 해당하는 하위 지역 코드 추가
            if selectTopRegion == getSubRegionCode["topRegion"] {
                subRegionCode.append(getSubRegionCode)
            }
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
            "userId": id    //사용자 ID
        ]
        
        //ID 찾기 API 호출
        let request = userAPI.requestFindId(parameters: parameters)
        request.execute(
            //API 호출 성공
            onSuccess: { (checkId) in
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
    
    //MARK: - 휴대전화번호 인증 요청
    func requestAuth(completion: @escaping (String) -> Void) {
        isAuthComplete = false
        authNumber = ""
        
        //휴대전화번호 입력 여부 확인
        if networkIDNumber.isEmpty || stationNumber.isEmpty || individualNumber.isEmpty {
            self.result = "success"
            self.message = "휴대전화번호를 입력하지 않았습니다."
            
            completion(self.result)
        } else {
            phoneNumber = networkIDNumber + stationNumber + individualNumber    //휴대전화번호
            
            let parameters = [
                "userPhone": phoneNumber
            ]
            
            //인증 번호 API 호출
            let request = userAPI.requestAuthNumber(parameters: parameters)
            request.execute(
                onSuccess: { (auth) in
                    
                    if auth.result == "success" {
                        self.isAuthRequest = true   //인증 요청 여부
                        self.receivedAuthNumber = auth.data!.authNumber //요청하여 받은 인증번호
                        
                        self.result = "success"
                        self.message = "인증 요청이 완료되었습니다."
                    }
                    else if auth.result == "fail" {
                        self.result = "registered"
                        self.message = "이미 가입된 전화번호입니다."
                    }
                    else {
                        self.result = "error"
                        self.message = "유효하지 않은 전화번호이거나, 인증 요청이 불가능 상태입니다."
                    }
                    
                    completion(self.result)
                },
                onFailure: { (error) in
                    self.result = "server error"
                    self.message = "서버와의 통신이 원활하지 않습니다."

                    completion(self.result)
                    print(error.localizedDescription)
                }
            )
        }
    }
    
    //MARK: - 인증 번호 확인
    func checkAuthNumber() {
        //인증 번호 입력 여부 확인
        if authNumber.isEmpty {
            message = "인증번호를 입력하지 않았습니다."
        } else {
            //API 호출로 받은 인증 번호와 입력한 인증 번호 비교
            if authNumber.contains(receivedAuthNumber) {
                message = "인증이 완료되었습니다."
                isAuthComplete = true
            } else {
                message = "인증번호가 일치하지 않습니다."
            }
        }
    }
    
    //MARK: - 회원가입 실행
    /// 회원가입 API를 통한 회원가입 실행
    /// - Parameter completion: 회원가입 결과
    func signUp(completion: @escaping (String) -> Void) {
        
        var userAge: String {
            if age.isEmpty {
                return "-"
            }
            else {
                return String(age)
            }
        }
        
        //API 호출 - Request Body
        let parameters = [
            "userType": userType,   //사용자 타입
            "userId": confirmId,    //중복 확인된 ID
            "userPassword": password,   //비밀번호
            "userName": name,   //사용자 명
            "userPhone": phoneNumber,   //휴대전화번호
            "userAge": userAge, //나이
            "userSex": selectSex,   //성별
            "userRegionMaster": selectTopRegion,  //상위 지역
            "userRegionDetail": selectSubRegion //하위 지역
        ]

        //회원가입 API 호출
        let request = userAPI.requestSignUp(parameters: parameters)
        request.execute(
            //API 호출 성공
            onSuccess: { (signUp) in
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
        } else {
            guard isNameValid() else {
                self.validMessage = "이름은 한글만 입력 가능합니다."
                return false
            }
        }
        
        //휴대전화번호 입력 여부 확인
        if networkIDNumber.isEmpty || stationNumber.isEmpty || individualNumber.isEmpty {
            self.validMessage = "휴대전화번호를 입력하지 않았습니다."
            return false
        }
        
        //인증 완료 여부 확인
        if !isAuthComplete {
            self.validMessage = "휴대전화번호 인증이 완료되지 않았습니다."
            return false
        }
        
        let filterAge = age.filter {$0.isNumber}    //압력 나이 숫자만 필터
        age = filterAge //필터된 숫자
        
        //나이 입력 여부 확인
        if !age.isEmpty {
            if Int(age)! <= 0 {
                self.validMessage = "0보다 큰 숫자를 입력하세요."
                return false
            }
        }
        
        //지역 선택 여부
        if selectTopRegion == "000" || selectSubRegion == "000" {
            self.validMessage = "지역을 선택하지 않았습니다."
            return false
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
    
    //MARK: - 비밀번호 확인 유효성 검사
    func isConfirmPasswordValid() -> Bool {
        let regExp = "^[a-zA-Z0-9~!@#\\$%\\^&\\*]{4,15}$"   //영문, 숫자, 특수문자
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", regExp)
        
        return passwordPredicate.evaluate(with: confirmPassword)
    }
    
    //MARK: - 이름 유효성 검사
    func isNameValid() -> Bool {
        let regExp = "^[가-힣ㄱ-ㅎㅏ-ㅣ]{2,10}$"  //한글
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", regExp)
        
        return passwordPredicate.evaluate(with: name)
    }
    
    //MARK: - 입력 완료 여부
    var isInputComplete: Bool {
        if id.isEmpty || password.isEmpty || confirmPassword.isEmpty || name.isEmpty || phoneNumber.isEmpty || !isAuthComplete || selectSubRegion == "000" {
            return false
        }
        else {
            return true
        }
    }
}
