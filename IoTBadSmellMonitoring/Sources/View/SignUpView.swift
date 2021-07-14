//
//  SignUpView.swift
//  IoTBadSmellMonitoring
//
//  Created by KJ on 2021/06/03.
//

import SwiftUI

//MARK: - 회원가입 화면
struct SignUpView: View {
    @Environment(\.presentationMode) var presentationMode   //Back 버튼 기능 추가에 필요
    
    @ObservedObject var viewUtil = ViewUtil()
    @ObservedObject var viewOptionSet = ViewOptionSet() //화면 Option Set
    @ObservedObject var signUpViewModel = SignUpViewModel() //회원가입 View Model
    
    var body: some View {
        ZStack {
            //로딩 표시 여부에 따라 표출
            if viewUtil.isLoading {
                viewUtil.loadingView()  //로딩 화면
                    .zIndex(1)
            }
            
            VStack {
                ScrollView {
                    VStack(alignment: .leading) {
                        AccountEntryField(viewUtil: viewUtil, signUpViewModel: signUpViewModel)    //회원가입 정보 입력 화면
                    }
                    .padding()
                }
                    
                AccountRegistButton(viewUtil: viewUtil, signUpViewModel: signUpViewModel)   //계정 등록 버튼
            }
            .navigationBarTitle(Text("회원가입"), displayMode: .inline) //Navigation Bar 타이틀
            .navigationBarBackButtonHidden(true)    //기본 Back 버튼 숨김
            .navigationBarItems(leading: BackButton())  //커스텀 Back 버튼 추가
        }
        .onAppear {
            signUpViewModel.getSexCode()    //성별 코드
            signUpViewModel.getRegionCode() //지역 코ㄷ
        }
        .popup(
            isPresented: $viewUtil.showToast,   //팝업 노출 여부
            type: .floater(verticalPadding: 40),
            position: .bottom,
            animation: .easeInOut(duration: 0.0),   //애니메이션 효과
            autohideIn: 2,  //팝업 노출 시간
            closeOnTap: false,
            closeOnTapOutside: false,
            view: {
                viewUtil.toast()    //팝업 화면
            }
        )
        .gesture(DragGesture(minimumDistance: 0.00001).onChanged {_ in
            viewUtil.dismissKeyboard() //키보드 닫기
        })
    }
}

//MARK: - 회원가입 정보 입력 화면
struct AccountEntryField: View {
    @ObservedObject var viewUtil: ViewUtil
    @ObservedObject var signUpViewModel: SignUpViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Section(
                header:HStack {
                    Text("아이디")
                    RequiredInputLabel()    //필수입력(*) Label
                }) {
                HStack {
                    TextField("5자리 이상 20자리 이하 입력", text: $signUpViewModel.id)
                        .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)    //첫 문자 항상 소문자
                        .keyboardType(.alphabet)    //키보드 타입 - 영문만 표시
                    DuplicateCheckButton(viewUtil: viewUtil, signUpViewModel: signUpViewModel)  //중복확인 버튼
                }
                TextFiledUnderLine()    //Text Field 밑줄
            }
            
            Section(
                header: HStack {
                    Text("비밀번호")
                    RequiredInputLabel()
                }) {
                SecureField("5자리 이상 15자리 이하 입력", text: $signUpViewModel.password)
                    .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)    //첫 문자 항상 소문자
                    .keyboardType(.alphabet)    //키보드 타입 - 영문만 표시
                TextFiledUnderLine()
            }
            
            Section(
                header: HStack {
                    Text("비밀번호 확인")
                    RequiredInputLabel()
                }) {
                SecureField("5자리 이상 15자리 이하 입력", text: $signUpViewModel.confirmPassword)
                    .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)    //첫 문자 항상 소문자
                    .keyboardType(.alphabet)    //키보드 타입 - 영문만 표시
                TextFiledUnderLine()
            }
            
            Section(
                header: HStack {
                    Text("이름")
                    RequiredInputLabel()
                }) {
                TextField("실명 입력", text: $signUpViewModel.name)
                    .autocapitalization(.none)    //첫 문자 항상 소문자
                    .keyboardType(.namePhonePad)
                TextFiledUnderLine()
            }
            
            Section(
                header: HStack {
                    Text("나이")
                    RequiredInputLabel()
                }) {
                TextField("나이", text: $signUpViewModel.age)
                    .keyboardType(.numberPad)
                TextFiledUnderLine()
            }
            
            Section(
                header: HStack {
                    Text("성별")
                    RequiredInputLabel()
                }) {
                VStack {
                    Picker(selection: $signUpViewModel.selectSex, label: Text("성별")) {
                        ForEach(0..<signUpViewModel.sexCode.count, id: \.self) { index in
                            Text(signUpViewModel.sexCode[index]["codeName"] ?? "")
                                .tag(signUpViewModel.sexCode[index]["code"] ?? "")
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())    //Picker Style 변경
                }
            }
            
            Section(
                header: HStack {
                    Text("지역")
                    RequiredInputLabel()
                }) {
                VStack {
                    Picker(selection: $signUpViewModel.selectRegion, label: Text("지역")) {
                        ForEach(0..<signUpViewModel.regionCode.count, id: \.self) { index in
//                            if index == 0 {
//                                Text("선택").tag("000")
//                            }
                            Text(signUpViewModel.regionCode[index]["codeName"] ?? "")
                                .tag(signUpViewModel.regionCode[index]["code"] ?? "")
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())    //Picker Style 변경
                }
            }
        }
    }
}

//MARK: - ID 중복확인 버튼
struct DuplicateCheckButton: View {
    @ObservedObject var viewUtil: ViewUtil
    @ObservedObject var signUpViewModel: SignUpViewModel
    
    var body: some View {
        Button(
            action: {
                viewUtil.dismissKeyboard() //키보드 닫기
                viewUtil.isLoading = true  //로딩 시작
                
                //ID 중복확인 실행
                signUpViewModel.checkId() { (result) in
                    viewUtil.isLoading = false   //로딩 종료
                    
                    //ID 유효성 검사가 Error가 아닌 경우
                    if result != "valid error" {
                        viewUtil.showToast = true
                        viewUtil.toastMessage = signUpViewModel.message
                    }
                    else {
                        viewUtil.showToast = true
                        viewUtil.toastMessage = signUpViewModel.validMessage
                    }
                }
            },
            label: {
                Text("중복확인")
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding()
                    .frame(maxHeight: 30)
                    .background(Color("Color_3498DB"))
            }
        )
    }
}

//MARK: - 계정 등록 버튼
struct AccountRegistButton: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var viewUtil: ViewUtil
    @ObservedObject var signUpViewModel: SignUpViewModel

    var body: some View {
        Button(
            action: {
                viewUtil.dismissKeyboard() //키보드 닫기
                
                //입력한 회원가입 정보 유효성 검사
                if !signUpViewModel.validate() {
                    viewUtil.showToast = true
                    viewUtil.toastMessage = signUpViewModel.validMessage
                }
                else {
                    viewUtil.isLoading = true   //로딩 시작

                    //회원가입 실행
                    signUpViewModel.signUp() { (result) in
                        viewUtil.isLoading = false   //로딩 종료
                        
                        viewUtil.showToast = true   //Toast 팝업
                        viewUtil.toastMessage = signUpViewModel.message

                        //회원가입 성공 시, 로그인 화면으로 이동
                        if result == "success" {
                            //현재시간 기준으로 1.5초 후 실행
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                self.presentationMode.wrappedValue.dismiss()    //Navigation View 닫기
                            }
                        }
                    }
                }
            },
            label: {
                Text("등록")
                    .font(/*@START_MENU_TOKEN@*/.title2/*@END_MENU_TOKEN@*/)
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding(/*@START_MENU_TOKEN@*/.horizontal/*@END_MENU_TOKEN@*/)
                    .frame(maxWidth: .infinity, maxHeight: 40)
                    .background(signUpViewModel.isInputComplete ? Color("Color_3498DB") : Color("Color_BEBEBE"))   //회원가입 정보 입력에 따른 배경색상 변경
            }
        )
        .disabled(!signUpViewModel.isInputComplete)    //회원가입 정보 입력에 따른 버튼 활성화
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
