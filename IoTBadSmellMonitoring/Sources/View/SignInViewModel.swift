//
//  SignInViewModel.swift
//  IoTBadSmellMonitoring
//
//  Created by KJ on 2021/06/03.
//

import Foundation

class SignInViewModel: ObservableObject {
    
    let userApi = UserApiService()
    let api = ApiService()
    
    @Published var signInModel: SignIn?
    
    @Published var id: String = ""   //이메일
    @Published var password: String = ""    //비밀번호
    @Published var status: Bool = false   //로그인 결과
    @Published var message: String = "" //로그인 결과 메시지
    
    //로그인 실행
    func signIn() {
        print("ID = \(id)")
        print("Password = \(password)")
        
        let body = ["userId": id, "userPassword": password]
        
//        userApi.requestSignIn(body) { (results) in
//            let jsonObject = try JSONSerialization.data(withJSONObject: results, options: .prettyPrinted)
//            let jsonData = try JSONDecoder.decode(signInModel.self, from: jsonObject)
//        }
        
//        api.request("base", "/api/userLogin", "GET", body) { (response) in
//            let jsonObject = try JSONSerialization.data(withJSONObject: response, options: .prettyPrinted)
//            let jsonData = try JSONDecoder.decode(signInModel.self, from: jsonObject)
//        }
        api.request("base", "/api/userLogin", "GET", body) { (response) in
            switch response.result {
            case .success:
                print("Value : \(response.value!)")
                print("Data : \(response.data!)")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
