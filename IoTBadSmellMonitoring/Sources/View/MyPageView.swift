//
//  MyPageView.swift
//  IoTBadSmellMonitoring
//
//  Created by guava on 2021/06/24.
//

import SwiftUI
import UserNotifications
import Combine

//MARK: - 마이페이지 화면

struct MyPageView: View {
    @Environment(\.presentationMode) var presentationMode   //Back 버튼 기능 추가에 필요
    @Environment(\.scenePhase) var scenePhase
    @ObservedObject var signInViewModel = SignInViewModel() //Sign In View Model
    @StateObject var sideMenuViewModel = SideMenuViewModel() //Sign In View Model
    
    @AppStorage("isSignIn") var isSignIn : Bool = true
    
    @EnvironmentObject var viewUtil: ViewUtil   //View Util
    @ObservedObject var viewOptionSet = ViewOptionSet()     //화면 Option Set
    @ObservedObject var myPageViewModel = MyPageViewModel() //My Page View Model
//    @EnvironmentObject var myPageViewModel: MyPageViewModel
    
    @StateObject private var stateViewUtil = ViewUtil()
    @StateObject private var stateWeatherViewModel = WeatherViewModel()
    @StateObject private var stateSmellViewModel = SmellReceptionViewModel()
    @StateObject private var stateSideMenuViewModel = SideMenuViewModel()
    @StateObject private var stateNoticeViewModel = NoticeViewModel()
    @StateObject private var stateMyPageViewModel = MyPageViewModel()
    @StateObject private var stateReceptionHistoryViewModel = ReceptionHistoryViewModel()
    
    var body: some View {
        let _ = print("mypage : " + String(sideMenuViewModel.isSignOut))
        //뒤로가기 버튼 클릭 시, 악취 접수 등록 화면 이동
        if viewUtil.isBack {
            //악취 접수 등록 화면
            SmellReceptionView()
                .environmentObject(stateViewUtil)
                .environmentObject(stateWeatherViewModel)
                .environmentObject(stateSmellViewModel)
                .environmentObject(stateSideMenuViewModel)
                .environmentObject(stateNoticeViewModel)
                .environmentObject(stateMyPageViewModel)
                .environmentObject(stateReceptionHistoryViewModel)
        }
        else {
            if !UserDefaults.standard.bool(forKey: "isSignIn") {
                SignInFailurePopupInPage()
            } else {
                //My Page 화면
                NavigationView {
                    ZStack {
                        //로딩 표시 여부에 따라 표출
                        if viewUtil.isLoading {
                            viewUtil.loadingView()  //로딩 화면
                        }
                        
                        VStack {
                            ScrollView {
                                VStack {
                                    Profile()   //프로필
                                    
                                    VerticalDividerLine()
                                    
                                    PushToggle(myPageViewModel: myPageViewModel)    //푸쉬(토글버튼)
                                    VerticalDividerLine()
                                    
                                    PasswordChange(myPageViewModel: myPageViewModel)    //비밀번호 변경 field
                                    
                                    //                                        deleteUser(myPageViewModel : myPageViewModel)
                                }
                            }
                            .padding(
                                UIDevice.isiPhoneSE()
                                ? EdgeInsets(top: 10, leading: 20, bottom: 0, trailing: 0)
                                : EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
                            )
                            
                            PasswordChangeButton(viewUtil: viewUtil, myPageViewModel: myPageViewModel)               //비밀번호 수정 버튼
                            
                            Spacer().frame(height: 1)
                        }
                    }
                    .navigationBarTitle(Text("My Page"), displayMode: .inline)  //Navigation Bar 타이틀
                    .navigationBarBackButtonHidden(true)    //기본 Back 버튼 숨김
                    .navigationBarItems(leading: viewUtil.backMenuButton()) //커스텀 Back 버튼 추가
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
                    .onAppear {
                        //사용자 정보에 저장된 푸시 알림 여부 상태에 따른 토글 버튼의 상태 변경
                        if UserDefaults.standard.object(forKey: "notificationStatus") != nil {
                            myPageViewModel.showToggle = UserDefaults.standard.bool(forKey: "notificationStatus")
                        }
                        else {
                            myPageViewModel.showToggle = UserDefaults.standard.bool(forKey: "notificationAuth")
                        }
                    }
                }.onChange(of: scenePhase) { newPahase in
                    if newPahase == .active {
                        signInViewModel.authSignIn() {result in
                            if result != "success" {
                                sideMenuViewModel.signOut()
                                UserDefaults.standard.set(false, forKey: "isSignIn")
                            }
                        }
                    }
                }
            }
        }
    }
}

//MARK: - 프로필
struct Profile: View {
    var body: some View  {
        VStack(spacing: 10) {
            //사용자 명
            HStack {
                Text(UserDefaults.standard.string(forKey: "userName") ?? "User Name")
                    .font(.title)
                    .fontWeight(.bold)
                
                Spacer()
            }
            
            //사용자 ID
            HStack {
                Text(UserDefaults.standard.string(forKey: "userId") ?? "User ID")
                    .fontWeight(.bold)
                
                Spacer()
            }
        }
    }
}

//MARK: - 푸쉬설정
struct PushToggle: View {
    @ObservedObject var myPageViewModel: MyPageViewModel
    
    @State var showAlert: Bool = false  //알림창 노출 여부
    @State var alert: Alert?    //알림창
    
    var body: some View  {
        HStack {
            Text("푸시 알림")
            
            Toggle("", isOn: $myPageViewModel.showToggle)
                .padding(.trailing, 250)
                .onChange(of: myPageViewModel.showToggle, perform: { toggleIsOn in
                    
                    UserDefaults.standard.set(toggleIsOn, forKey: "notificationStatus") //푸시 알림 상태 저장
                    //토글 상태 ON
                    if toggleIsOn {
                        myPageViewModel.showToggle = true
                        
                        //알림 권한 상태 체크 후 푸시 알림 실행
                        myPageViewModel.checkAuthStatus() { status in
                            
                            myPageViewModel.scheduleNotification()  //푸시 알림 스케쥴 실행
                            
                            //알림 권한이 없는 경우, 알림 설정 이동 알림창 호출
                            if !status {
                                showAlert = true    //알림창 호출
                                alert = myPageViewModel.requestAuthAlert()  //알림 설정 이동 알림창
                            }
                        }
                    }
                    //토글 상태 OFF
                    else {
                        myPageViewModel.showToggle = false
                        myPageViewModel.removeNotification()    //푸시 알림 정보 삭제
                    }
                })
                .alert(isPresented: $showAlert) {
                    alert!
                }
        }
    }
}

//MARK: - 비밀번호 변경 field
struct PasswordChange: View {
    @ObservedObject var myPageViewModel: MyPageViewModel
    
    var body: some View  {
        VStack(alignment: .leading) {
            //현재 비밀번호
            Section(
                header:HStack {
                    Text("현재 비밀번호")
                    RequiredInputLabel()    //필수입력(*) Label
                }) {
                SecureField("4자리 이상 15자리 이하 입력", text: $myPageViewModel.currentPassword)
                    .autocapitalization(.none)    //첫 문자 항상 소문자
                    .keyboardType(.alphabet)    //키보드 타입 - 영문만 표시
                TextFieldUnderLine()    //Text Field 밑줄
            }
            
            //새 비밀번호
            Section(
                header:HStack {
                    Text("새 비밀번호")
                    RequiredInputLabel()    //필수입력(*) Label
                }) {
                SecureField("4자리 이상 15자리 이하 입력", text: $myPageViewModel.newPassword)
                    .autocapitalization(.none)    //첫 문자 항상 소문자
                    .keyboardType(.alphabet)    //키보드 타입 - 영문만 표시
                TextFieldUnderLine()    //Text Field 밑줄
            }
            
            //새 비밀번호 확인
            Section(
                header:HStack {
                    Text("새 비밀번호 확인")
                    RequiredInputLabel()    //필수입력(*) Label
                }) {
                SecureField("4자리 이상 15자리 이하 입력", text: $myPageViewModel.confirmPassword)
                    .autocapitalization(.none)    //첫 문자 항상 소문자
                    .keyboardType(.alphabet)    //키보드 타입 - 영문만 표시
                TextFieldUnderLine()    //Text Field 밑줄
            }
            //새 비밀번호 확인
            Section(
                header:HStack {
                    
                }) {
                    Button(action: {
                        myPageViewModel.showAlert = true  //알람 노출 여부
                        myPageViewModel.alert = myPageViewModel.deleteUserAlert()  //알람 생성
                        print("delete")
                    })
                    {
                        HStack{
                            Image(systemName: "trash")
                                .font(.system(size: 15))
                            Text("회원탈퇴")
                                .fontWeight(.semibold)
                                .font(.system(size: 15))
                        }
                        .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                        .foregroundColor(.white)
                        .background(Color(red:240 / 255 , green : 50 / 255 , blue: 20 / 255).ignoresSafeArea())
                        .cornerRadius(10)
                    }
                    .alert(isPresented: $myPageViewModel.showAlert) {
                        myPageViewModel.alert! //알림창 호출
                    }
            }
                .padding(EdgeInsets(top: 1, leading: 0, bottom: 0, trailing: 0))
        }
    }
}

//MARK: - 비밀번호 수정 버튼
struct PasswordChangeButton: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var viewUtil: ViewUtil
    @ObservedObject var myPageViewModel: MyPageViewModel
    
    var body: some View {
        Button(
            action: {
                viewUtil.dismissKeyboard() //키보드 닫기
                viewUtil.isLoading = true  //로딩 실행
                
                //로그인 실행
                myPageViewModel.signIn() { (result) in
                    //현재 비밀번호가 일치 하는 경우
                    if result == "success" {
                        //유효성 검사 성공이 아닌 경우 Toast 팝업 메시지 호출
                        if !myPageViewModel.validate() {
                            viewUtil.isLoading = false  //로딩 종료
                            
                            viewUtil.showToast = true
                            viewUtil.toastMessage = myPageViewModel.validMessage
                        }
                        //새 비밀번호 유효성 검사가 성공인 경우, 비밀번호 변경 실행
                        else {
                            myPageViewModel.passwordChange() { (result) in
                                viewUtil.isLoading = false  //로딩 종료

                                viewUtil.showToast = true
                                viewUtil.toastMessage = myPageViewModel.message
                            }
                        }
                    }
                    //로그인 성공이 아닌 경우(현재비밀번호 불일치) Toast 팝업 메시지 호출
                    else {
                        viewUtil.isLoading = false  //로딩 종료
                        
                        viewUtil.showToast = true
                        viewUtil.toastMessage = myPageViewModel.message
                    }
                }
            },
            label: {
                Text("수정")
                    .font(/*@START_MENU_TOKEN@*/.title2/*@END_MENU_TOKEN@*/)
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding(/*@START_MENU_TOKEN@*/.horizontal/*@END_MENU_TOKEN@*/)
                    .frame(maxWidth: .infinity, maxHeight: 40)
                    .background(myPageViewModel.isInputComplete ? Color("Color_3498DB") : Color("Color_BEBEBE"))   //회원가입 정보 입력에 따른 배경색상 변경
            }
        )
        .disabled(!myPageViewModel.isInputComplete)    //비밀번호 수정 정보 입력에 따른 버튼 활성화
    }
}

////MARK: - 회원탈퇴
//struct deleteUser: View {
//    @ObservedObject var myPageViewModel: MyPageViewModel
//    var body: some View {
//        
//    }
//}

//MARK: - 로그인 실패 알림 팝업
struct SignInFailurePopupInPage: View {
    
    var body: some View {
        NavigationView {
            GeometryReader { geometryReader in
                VStack {
                    VStack {
                        Text("로그인 실패")
                            .fontWeight(.bold)
                        
                        VStack {
                            HorizontalDividerLine()
                            
                            Text("로그인 정보가 일치하지 않아 로그인에 실패하였습니다.앱을 종료합니다.")
                                .font(.subheadline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                            
                            HorizontalDividerLine()
                            
                            // 앱 종료
                            Button(
                                
                                action: {
                                    UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        exit(0)
                                    }
                                },
                                label: {
                                    Text("확인")
                                        .fontWeight(.bold)
                                        .foregroundColor(Color.white)
                                        .padding(.horizontal)
                                        .frame(maxWidth: .infinity, maxHeight: 30)
                                        .background(Color("Color_3498DB"))
                                        .cornerRadius(5)
                                        .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
                                }
                            )
                            .padding([.bottom, .leading, .trailing], 10)
                        }
                    }
                    .padding(.top)
                    .background(Color.white)
                    .cornerRadius(5.0)
                    .frame(maxWidth: .infinity, maxHeight: 
                            UIDevice.isiPhoneSE()
                           ? geometryReader.size.height/2.8
                           : geometryReader.size.height/3.8)
                }
                .padding()
                .frame(width: geometryReader.size.width, height: geometryReader.size.height)
                .background(Color.black.opacity(0.5))
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
}


//MARK: - preview

struct MyPageView_Previews: PreviewProvider {
    static var previews: some View {
        MyPageView()
            .environmentObject(ViewUtil())
    }
}
