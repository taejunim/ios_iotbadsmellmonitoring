//
//  SignUpView.swift
//  IoTBadSmellMonitoring
//
//  Created by KJ on 2021/06/03.
//

import SwiftUI
import WebKit

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
            
            //개인정보 수집 동의 여부에 따라 화면 변경
            if !signUpViewModel.isPrivacyAgree {
                VStack {
                    ScrollView {
                        PrivacyConentView(signUpViewModel: signUpViewModel) //개인정보 처리방침 내용 화면
                    }

                    PrivacyConfirmButton(viewUtil: viewUtil, signUpViewModel: signUpViewModel)  //개인정보 수집 동의 확인 버튼
                    
                    Spacer().frame(height: 1)
                }
                .navigationBarTitle(Text("개인정보 처리방침"), displayMode: .inline) //Navigation Bar 타이틀
                .navigationBarBackButtonHidden(true)    //기본 Back 버튼 숨김
                .navigationBarItems(leading: BackButton())  //커스텀 Back 버튼 추가
            } else {
                VStack {
                    ScrollView {
                        AccountEntryField(viewUtil: viewUtil, signUpViewModel: signUpViewModel)    //회원가입 정보 입력 화면
                    }

                    AccountRegistButton(viewUtil: viewUtil, signUpViewModel: signUpViewModel)   //계정 등록 버튼
                    
                    Spacer().frame(height: 1)
                }
                .navigationBarTitle(Text("회원가입"), displayMode: .inline) //Navigation Bar 타이틀
                .navigationBarBackButtonHidden(true)    //기본 Back 버튼 숨김
                .navigationBarItems(leading: SignUpBackButton(signUpViewModel: signUpViewModel))  //커스텀 Back 버튼 추가
                .onAppear {
                    signUpViewModel.getSexCode()    //성별 코드
                    signUpViewModel.getRegionCode() //지역 코드
                }
            }
        }
        .onDisappear {
            signUpViewModel.initSignUpView()    //회원가입 화면 초기화
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

//MARK: - 개인정보 처리방침
struct PrivacyConentView: View {
    @ObservedObject var signUpViewModel: SignUpViewModel
    
    var body: some View {
        VStack {
            //개인정보 수집 및 이용 동의 버튼
            Button(
                action: {
                    signUpViewModel.isCheckPrivacy.toggle() //동의 체크 여부 처리
                },
                label: {
                    HStack(spacing: 1) {
                        Image(systemName: signUpViewModel.isCheckPrivacy ? "checkmark.square.fill" : "square")
                            .font(.headline)
                            .foregroundColor(signUpViewModel.isCheckPrivacy ? Color("Color_3498DB") : Color("Color_BEBEBE"))
                            
                        Text("개인정보 수집 및 이용 동의")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(Color.black)
                        
                        Text("(필수)")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(Color("Color_E4513D"))
                        
                        Spacer()
                    }
                }
            )
            
            //개인정보 처리방침 내용 - Web View
            WebView(loadURL: "http://101.101.216.193:8007/agreement")
                .frame(height: 200)
                .border(Color("Color_BEBEBE"))
        }
        .padding()
    }
}

//MARK: - 개인정보 처리방침 확인 버튼
struct PrivacyConfirmButton: View {
    @ObservedObject var viewUtil: ViewUtil
    @ObservedObject var signUpViewModel: SignUpViewModel

    var body: some View {
        Button(
            action: {
                signUpViewModel.isPrivacyAgree = true   //개인정보 처리 동의 처리
            },
            label: {
                Text("확인")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, maxHeight: 40)
                    .background(signUpViewModel.isCheckPrivacy ? Color("Color_3498DB") : Color("Color_BEBEBE"))
            }
        )
        .disabled(!signUpViewModel.isCheckPrivacy)
    }
}

//MARK: - 회원가입 뒤로가기 버튼
///버튼 클릭 시, 개인정보 처리방침 화면으로 이동
struct SignUpBackButton: View {
    @ObservedObject var signUpViewModel: SignUpViewModel
    
    var body: some View {
        Button(
            action: {
                signUpViewModel.isPrivacyAgree = false  //개인정보 처리 미동의 처리
            },
            label: {
                HStack {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                }
                .padding(.trailing)
            }
        )
    }
}

//MARK: - 회원가입 정보 입력 화면
struct AccountEntryField: View {
    @ObservedObject var viewUtil: ViewUtil
    @ObservedObject var signUpViewModel: SignUpViewModel
    
    enum PhoneNumberField: Hashable {
        case focusStationNumber
        case focusIndividualNumber
    }

    @FocusState var focusPhoneNumberField: PhoneNumberField?    //포커스 휴대전화번호 필드
    
    var body: some View {
        VStack(alignment: .leading) {
            Section(
                header:HStack {
                    Text("아이디")
                    RequiredInputLabel()    //필수입력(*) Label
                }) {
                    HStack {
                        TextField("4자리 이상 20자리 이하 입력", text: $signUpViewModel.id)
                            .autocapitalization(.none)  //첫 문자 항상 소문자
                            .keyboardType(.alphabet)    //키보드 타입 - 영문만 표시
                            .keyboardType(.default) //키보드 타입 - Default로 변경
                        DuplicateCheckButton(viewUtil: viewUtil, signUpViewModel: signUpViewModel)  //중복확인 버튼
                    }
                    TextFieldUnderLine()    //Text Field 밑줄
                }
            
            Section(
                header: HStack {
                    Text("비밀번호")
                    RequiredInputLabel()
                }) {
                    SecureField("4자리 이상 15자리 이하 입력", text: $signUpViewModel.password)
                        .autocapitalization(.none)    //첫 문자 항상 소문자
                        .keyboardType(.alphabet)    //키보드 타입 - 영문만 표시
                    TextFieldUnderLine()
                }
            
            Section(
                header: HStack {
                    Text("비밀번호 확인")
                    RequiredInputLabel()
                }) {
                    SecureField("4자리 이상 15자리 이하 입력", text: $signUpViewModel.confirmPassword)
                        .autocapitalization(.none)    //첫 문자 항상 소문자
                        .keyboardType(.alphabet)    //키보드 타입 - 영문만 표시
                    TextFieldUnderLine()
                }
            
            Section(
                header: HStack {
                    Text("이름")
                    RequiredInputLabel()
                }) {
                    TextField("실명 입력", text: $signUpViewModel.name)
                        .autocapitalization(.none)    //첫 문자 항상 소문자
                        .keyboardType(.namePhonePad)
                    TextFieldUnderLine()
                }
            
            Section(
                header: HStack {
                    Text("휴대전화번호")
                    RequiredInputLabel()
                }) {
                    HStack {
                        TextField("", text: $signUpViewModel.networkIDNumber)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                            .onChange(of: signUpViewModel.networkIDNumber) { (text) in
                                if text.count == 3 {
                                    focusPhoneNumberField = .focusStationNumber //포커스 이동
                                }
                            }
                        
                        Text("-")
                        
                        TextField("", text: $signUpViewModel.stationNumber)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                            .focused($focusPhoneNumberField, equals: .focusStationNumber)
                            .onChange(of: signUpViewModel.stationNumber) { (text) in
                                if text.count == 4 {
                                    focusPhoneNumberField = .focusIndividualNumber  //포커스 이동
                                }
                            }
                        
                        Text("-")
                        
                        TextField("", text: $signUpViewModel.individualNumber)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                            .focused($focusPhoneNumberField, equals: .focusIndividualNumber)
                            .onChange(of: signUpViewModel.individualNumber) { (text) in
                                if text.count == 4 {
                                    viewUtil.dismissKeyboard()  //키보드 닫기
                                }
                            }
                        
                        AuthRequestButton(viewUtil: viewUtil, signUpViewModel: signUpViewModel) //인증 요청 버튼
                    }
                    
                    TextFieldUnderLine()
                }
            
            Section(
                header: HStack {
                    Text("인증번호")
                    RequiredInputLabel()
                }) {
                    HStack {
                        TextField("인증번호 입력", text: $signUpViewModel.authNumber)
                            .keyboardType(.numberPad)
                        
                        AuthCheckButton(viewUtil: viewUtil, signUpViewModel: signUpViewModel)   //인증 확인 버튼
                    }
                    TextFieldUnderLine()
                }
            
            Section(
                header: HStack {
                    Text("나이")
                }) {
                    TextField("숫자 입력", text: $signUpViewModel.age)
                        .keyboardType(.numberPad)
                    TextFieldUnderLine()
                }
            
            Section(
                header: HStack {
                    Text("성별")
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
                    HStack {
                        //상위 지역 Picker
                        Menu {
                            Picker(
                                selection: $signUpViewModel.selectTopRegionIndex,
                                label: Text("상위 지역"),
                                content: {
                                    Text("선택").tag(-1)
                                    
                                    ForEach(0..<signUpViewModel.topRegionCode.count, id: \.self) { (index) in
                                        Text(signUpViewModel.topRegionCode[index]["codeName"] ?? "")
                                            .tag(index)
                                    }
                                }
                            )
                            .onChange(of: signUpViewModel.selectTopRegion) { (value) in
                                signUpViewModel.changeSubRegionPicker(selectTopRegion: value)   //상위 지역 선택 시, 하위 지역 Picker 변경
                            }
                            .labelsHidden()
                            .pickerStyle(InlinePickerStyle())    //Picker Style 변경
                        } label: {
                            Text(signUpViewModel.selectTopRegionName)
                                .frame(maxWidth: .infinity, maxHeight: 25)
                                .background(Color("Color_3498DB"))
                                .cornerRadius(5)
                                .accentColor(Color.white)
                                .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
                        }
                        .frame(height: 25)
                        
                        //하위 지역 Picker
                        Menu {
                            Picker(
                                selection: $signUpViewModel.selectSubRegionIndex,
                                label: Text("하위 지역"),
                                content: {
                                    Text("선택").tag(-1)
                                    
                                    ForEach(0..<signUpViewModel.subRegionCode.count, id: \.self) { (index) in
                                        Text(signUpViewModel.subRegionCode[index]["codeName"] ?? "")
                                            .tag(index)
                                    }
                                }
                            )
                            .labelsHidden()
                            .pickerStyle(InlinePickerStyle())    //Picker Style 변경
                        } label: {
                            Text(signUpViewModel.selectSubRegionName)
                                .frame(maxWidth: .infinity, maxHeight: 25)
                                .background(Color("Color_3498DB"))
                                .cornerRadius(5)
                                .accentColor(Color.white)
                                .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
                        }
                        .frame(height: 25)
                    }
                }
        }
        .padding()
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
                    .frame(minWidth: 95, maxHeight: 25)
                    .background(Color("Color_3498DB"))
                    .cornerRadius(5)
                    .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
            }
        )
    }
}

//MARK: - 인증 요청 버튼
struct AuthRequestButton: View {
    @ObservedObject var viewUtil: ViewUtil
    @ObservedObject var signUpViewModel: SignUpViewModel
    
    var body: some View {
        Button(
            action: {
                viewUtil.dismissKeyboard() //키보드 닫기
                viewUtil.isLoading = true  //로딩 시작
                
                //인증 요청
                signUpViewModel.requestAuth() { (result) in
                    viewUtil.isLoading = false   //로딩 종료
                    
                    viewUtil.showToast = true
                    viewUtil.toastMessage = signUpViewModel.message
                }
            },
            label: {
                Text("인증요청")
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding()
                    .frame(minWidth: 95, maxHeight: 25)
                    .background(Color("Color_3498DB"))
                    .cornerRadius(5)
                    .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
            }
        )
    }
}

//MARK: - 인증 확인 버튼
struct AuthCheckButton: View {
    @ObservedObject var viewUtil: ViewUtil
    @ObservedObject var signUpViewModel: SignUpViewModel
    
    var body: some View {
        Button(
            action: {
                viewUtil.dismissKeyboard() //키보드 닫기
                
                signUpViewModel.checkAuthNumber()   //인증 번호 확인
                
                viewUtil.showToast = true
                viewUtil.toastMessage = signUpViewModel.message
            },
            label: {
                Text("인증확인")
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding()
                    .frame(minWidth: 95, maxHeight: 25)
                    .background(signUpViewModel.isAuthRequest ? Color("Color_3498DB") : Color("Color_BEBEBE"))
                    .cornerRadius(5)
                    .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
            }
        ).disabled(!signUpViewModel.isAuthRequest)
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
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding(.horizontal)
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
