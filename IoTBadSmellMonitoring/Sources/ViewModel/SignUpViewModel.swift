//
//  SignUpViewModel.swift
//  IoTBadSmellMonitoring
//
//  Created by KJ on 2021/06/03.
//

import Foundation

class SignUpViewModel: ObservableObject {
    
    @Published var userType: String = ""    //사용자 타입 - Data Type 임시
    @Published var name: String = ""    //이름
    @Published var email: String = ""   //이메일
    @Published var password: String = ""    //비밀번호
    @Published var confirmPassword: String = "" //비밀번호 확인
    @Published var phoneNumber: String = "" //전화번호
    
    @Published var sex: Int = 0
    @Published var age: Int = 0
    
    func printValue() {
        print("E-Mail = \(email)")
    }
}
