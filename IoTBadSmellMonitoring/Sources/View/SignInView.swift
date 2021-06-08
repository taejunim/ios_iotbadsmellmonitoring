//
//  SignInView.swift
//  IoTBadSmellMonitoring
//
//  Created by KJ on 2021/06/03.
//

import SwiftUI

struct SignInView: View {
    
    @ObservedObject var signInViewModel = SignInViewModel()

    var body: some View {
        //로그인 화면
        if signInViewModel.status == false {
            NavigationView {
                VStack {
                    TextField("아이디", text: $signInViewModel.id)
                        .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)    //첫 문자 항상 소문자
                        .keyboardType(.emailAddress)    //키보드 타입 - 이메일 입력 형식
                    TextFiledUnderLine()    //Text Field 밑줄
                    
                    SecureField("비밀번호", text: $signInViewModel.password)
                        .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)    //첫 문자 항상 소문자
                        .keyboardType(/*@START_MENU_TOKEN@*/.alphabet/*@END_MENU_TOKEN@*/)    //키보드 타입 - 영문만 표시
                    TextFiledUnderLine()
                    
                    HStack {
                        SignInButton(signInViewModel: signInViewModel)  //로그인 버튼
                        Spacer().frame(width: 1)    //버튼 사이 간격
                        SignUpButton()  //회원가입 화면 이동 버튼
                    }
                    
                    FindPasswordButton()    //비밀번호 찾기 버튼
                }
                .padding()
            }
        }
        //로그인 성공 시, 메인 화면 이동
        else if signInViewModel.status == true {
            
        }
    }
}

//로그인 버튼
struct SignInButton: View {
    
    @ObservedObject var signInViewModel: SignInViewModel
    
    var body: some View {
        Button(action: {
            signInViewModel.signIn()    //로그인 실행
        }) {
            Text("로그인")
                .fontWeight(.bold)
                .foregroundColor(Color.white)
                .padding(/*@START_MENU_TOKEN@*/.horizontal/*@END_MENU_TOKEN@*/)
                .frame(maxWidth: .infinity, maxHeight: 35)
                .background(/*@START_MENU_TOKEN@*//*@PLACEHOLDER=View@*/Color("Color_3498DB")/*@END_MENU_TOKEN@*/)
        }
    }
}

//회원가입 화면 이동 버튼
struct SignUpButton: View {
    var body: some View {
        NavigationLink(
            destination: SignUpView(),  //회원가입 화면 이동
            label: {
                Text("회원가입")
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding(/*@START_MENU_TOKEN@*/.horizontal/*@END_MENU_TOKEN@*/)
                    .frame(maxWidth: .infinity, maxHeight: 35)
                    .background(/*@START_MENU_TOKEN@*//*@PLACEHOLDER=View@*/Color("Color_535353")/*@END_MENU_TOKEN@*/)
            })
    }
}

//비밀번호 찾기 버튼
struct FindPasswordButton: View {
    var body: some View {
        NavigationLink(
            destination: SignUpView(),  //비밀번호 찾기 화면 이동
            label: {
                Text("비밀번호를 잊으셨나요?")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Color.gray)
                    .underline()
            })
            .padding(.top)
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
