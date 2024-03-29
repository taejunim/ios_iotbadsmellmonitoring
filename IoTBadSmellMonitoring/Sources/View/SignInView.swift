//
//  SignInView.swift
//  IoTBadSmellMonitoring
//
//  Created by KJ on 2021/06/03.
//

import SwiftUI
import CoreLocation

//MARK: - 로그인 화면

struct SignInView: View {
    @ObservedObject var location = Location()   //Location
    @ObservedObject var signInViewModel = SignInViewModel() //Sign In View Model
    
    @StateObject private var viewUtil = ViewUtil()  //View Util
    @StateObject private var weatherViewModel = WeatherViewModel()  //Weater View Model
    @StateObject private var smellViewModel = SmellReceptionViewModel() //Smell Reception View Model
    @StateObject private var sideMenuViewModel = SideMenuViewModel()    //Side Menu View Model
    @StateObject private var noticeViewModel = NoticeViewModel()    //Notice View Model
    @StateObject private var myPageViewModel = MyPageViewModel()
    @StateObject private var receptionHistoryViewModel = ReceptionHistoryViewModel()
    
    var body: some View {
        //로그인 성공 시, 냄새 접수 화면 이동
        if signInViewModel.result == "success" {
            SmellReceptionView()    //냄새 접수 화면
                .environmentObject(viewUtil)
                .environmentObject(weatherViewModel)
                .environmentObject(smellViewModel)
                .environmentObject(sideMenuViewModel)
                .environmentObject(noticeViewModel)
                .environmentObject(myPageViewModel)
                .environmentObject(receptionHistoryViewModel)
        }
        else {
            ZStack {
                //로딩 표시 여부에 따라 표출
                if viewUtil.isLoading {
                    viewUtil.loadingView()  //로딩 화면
                        .zIndex(1)
                }
                
                NavigationView {
                    VStack {
                        SignInEntryField(signInViewModel: signInViewModel)    //아이디, 비밀번호 입력 화면
                        
                        HStack {
                            SignInButton(viewUtil: viewUtil, signInViewModel: signInViewModel)  //로그인 버튼
                            
                            Spacer().frame(width: 1)    //버튼 사이 간격
                            
                            SignUpButton()  //회원가입 화면 이동 버튼
                        }
                        
                        FindPasswordButton(viewUtil: viewUtil, signInViewModel: signInViewModel)    //비밀번호 찾기 버튼
                    }
                    .padding()
                }
                .navigationBarHidden(true)  //Navigation Bar 비활성화
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
}

//MARK: - 로그인 정보 입력 화면
struct SignInEntryField: View {
    @ObservedObject var signInViewModel: SignInViewModel
    
    var body: some View {
        //아이디 입력 창
        TextField("아이디", text: $signInViewModel.id)
            .autocapitalization(.none)    //첫 문자 항상 소문자
            .keyboardType(.alphabet)    //키보드 타입 - 영문만 표시
        TextFieldUnderLine()    //Text Field 밑줄
        
        //비밀번호 입력 창
        SecureField("비밀번호", text: $signInViewModel.password)
            .autocapitalization(.none)    //첫 문자 항상 소문자
            .keyboardType(.alphabet)    //키보드 타입 - 영문만 표시
        TextFieldUnderLine()
    }
}

//MARK: - 로그인 버튼
struct SignInButton: View {
    @ObservedObject var viewUtil: ViewUtil
    @ObservedObject var signInViewModel: SignInViewModel
    
    var body: some View {
        Button(
            action: {
                viewUtil.dismissKeyboard() //키보드 닫기

                //입력한 로그인 정보 유효성 검사
                if !signInViewModel.validate() {
                    viewUtil.showToast = true
                    viewUtil.toastMessage = signInViewModel.validMessage
                }
                else {
                    viewUtil.isLoading = true   //로딩 시작

                    //로그인 실행
                    signInViewModel.signIn() { (result) in
                        viewUtil.isLoading = false  //로딩 종료

                        //로그인 성공이 아닌 경우 Toast 팝업 메시지 호출
                        if result != "success" {
                            viewUtil.showToast = true
                            viewUtil.toastMessage = signInViewModel.message
                        }
                    }
                }
            },
            label: {
                Text("로그인")
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, maxHeight: 35)
                    .background(Color("Color_3498DB"))
            }
        )
    }
}

//MARK: - 회원가입 화면 이동 버튼
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
                    .background(Color("Color_5E5E5E"))
            }
        )
    }
}

//MARK: - 비밀번호 찾기 버튼
struct FindPasswordButton: View {
    @ObservedObject var viewUtil: ViewUtil
    @ObservedObject var signInViewModel: SignInViewModel
    
    var body: some View {
        Button(
            action: {
                let resultMessage = signInViewModel.findPassword()
                
                viewUtil.showToast = true
                viewUtil.toastMessage = resultMessage
            },
            label: {
                Text("비밀번호를 잊으셨나요?")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Color.gray)
                    .underline()
            }
        )
        .padding(.top)
    }
}


struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
            .environmentObject(ViewUtil())
    }
}
