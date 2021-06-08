//
//  SignUpView.swift
//  IoTBadSmellMonitoring
//
//  Created by KJ on 2021/06/03.
//

import SwiftUI

struct SignUpView: View {
    
    @ObservedObject var signUpViewModel = SignUpViewModel()
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading) {
                    AccountInforInputView(signUpViewModel: signUpViewModel)    //회원가입 정보 입력 화면
                }
                .padding()
            }
            
            CreateAccountButton(signUpViewModel: signUpViewModel)   //계정 생성 버튼
        }
        .navigationBarTitle("회원가입", displayMode: .inline)
        //.navigationBarBackButtonHidden(true)
    }
}

//회원가입 정보 입력 화면
struct AccountInforInputView: View {
    
    @ObservedObject var signUpViewModel: SignUpViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Section(
                header: HStack {
                    Text("아이디")
                    RequiredInputLabel()    //필수입력(*) Label
                }) {
                
                HStack {
                    TextField("아이디 20자리 이하 입력", text: $signUpViewModel.email)
                    DuplicateCheckButton()  //중복조회 버튼
                }
                
                TextFiledUnderLine()    //Text Field 밑줄
            }
            
            Section(
                header: HStack {
                    Text("비밀번호")
                    RequiredInputLabel()
                }) {
                
                TextField("비밀번호 15자리 이하 입력", text: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Value@*/.constant("")/*@END_MENU_TOKEN@*/)
                TextFiledUnderLine()
            }
            
            Section(
                header: HStack {
                    Text("비밀번호 확인")
                    RequiredInputLabel()
                }) {
                
                TextField("비밀번호 15자리 이하 입력", text: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Value@*/.constant("")/*@END_MENU_TOKEN@*/)
                TextFiledUnderLine()
            }
            
            Section(
                header: HStack {
                    Text("이름")
                    RequiredInputLabel()
                }) {
                
                TextField("실명 입력", text: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Value@*/.constant("")/*@END_MENU_TOKEN@*/)
                TextFiledUnderLine()
            }
            
            Section(
                header: HStack {
                    Text("나이")
                    RequiredInputLabel()
                }) {
                
                Stepper(value: $signUpViewModel.age) {
                    TextField("", value: $signUpViewModel.age, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                }
                TextFiledUnderLine()
            }
            
            Section(
                header: HStack {
                    Text("성별")
                    RequiredInputLabel()
                }) {
                
                VStack {
                    Picker(selection: $signUpViewModel.sex, label: Text("성별")) {
                        Text("남").tag(0)
                        Text("여").tag(1)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        }
    }
}

//아이디 중복 조회 버튼
struct DuplicateCheckButton: View {
    var body: some View {
        Button(action: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/{}/*@END_MENU_TOKEN@*/) {
            Text("중복조회")
                .fontWeight(.bold)
                .foregroundColor(Color.white)
                .padding()
                .frame(maxHeight: 30)
                .background(/*@START_MENU_TOKEN@*//*@PLACEHOLDER=View@*/Color("Color_3498DB")/*@END_MENU_TOKEN@*/)
        }
    }
}

//계정 생성 버튼
struct CreateAccountButton: View {
    
    @ObservedObject var signUpViewModel: SignUpViewModel
    
    var body: some View {
        Button(action: {
            signUpViewModel.printValue()    //계정 생성 실행
        }) {
            Text("계정 생성")
                .font(/*@START_MENU_TOKEN@*/.title2/*@END_MENU_TOKEN@*/)
                .fontWeight(.bold)
                .foregroundColor(Color.white)
                .padding(/*@START_MENU_TOKEN@*/.horizontal/*@END_MENU_TOKEN@*/)
                .frame(maxWidth: .infinity, maxHeight: 40)
                .background(/*@START_MENU_TOKEN@*//*@PLACEHOLDER=View@*/Color("Color_3498DB")/*@END_MENU_TOKEN@*/)
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
