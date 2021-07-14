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
    @ObservedObject var viewUtil = ViewUtil()
    @ObservedObject var viewOptionSet = ViewOptionSet() //화면 Option Set
    
    @ObservedObject var myPageViewModel = MyPageViewModel()
    
    var body: some View {
        ZStack {
            //로딩 표시 여부에 따라 표출
            if viewUtil.isLoading {
                viewUtil.loadingView()  //로딩 화면
            }
            
            VStack {
                ScrollView {
                    VStack(alignment: .leading) {
                        Profile(viewUtil: viewUtil, myPageViewModel: myPageViewModel).padding()          //프로필
                        Divider()
                        PushToggle(viewUtil: viewUtil, myPageViewModel: myPageViewModel).padding()       //푸쉬(토글버튼)
                        Divider()
                        PasswordChange(viewUtil: viewUtil, myPageViewModel: myPageViewModel).padding()   //비밀번호 변경 field
                    }
                }
                PasswordChangeButton(viewUtil: viewUtil, myPageViewModel: myPageViewModel)               //비밀번호 수정 버튼
            }
        }
        .navigationBarTitle(Text("My Page"), displayMode: .inline) //Navigation Bar 타이틀
        .navigationBarBackButtonHidden(true)                       //기본 Back 버튼 숨김
        .navigationBarItems(leading: BackButton())                 //커스텀 Back 버튼 추가
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

//MARK: - 프로필
struct Profile: View {
    @ObservedObject var viewUtil: ViewUtil
    @ObservedObject var myPageViewModel = MyPageViewModel()
    
    var body: some View  {
        HStack {
            Image("")   //프로필 이미지
                .frame(width: 100, height: 100)
                .background(Color.black)
                .clipShape(Circle())
            VStack(alignment: .leading){
                Text("홍길동") //user name
                    .font(.title)
                    .fontWeight(.bold)
                Text("test 1234") //user ID
                
            }.padding(.leading, 10)
        }
    }
}
//MARK: - 푸쉬설정
struct PushToggle: View {
    @ObservedObject var viewUtil: ViewUtil
    @ObservedObject var myPageViewModel = MyPageViewModel()
    
    @State var showToggle = true
    var body: some View  {
        VStack {
            Toggle("푸시", isOn: $showToggle)
                .padding(.trailing, 250)
                .onReceive(Just(showToggle), perform: { toggleIsOn in
                    if toggleIsOn {
                        print("Schedule")
                        MyPageViewModel.instance.scheduleNotification()
                    }
                    else {
                        print("No Schedule")
                    }
                })
            
            if showToggle{
                Button("사용자 허락"){
                    MyPageViewModel.instance.requestAuthorization()
                }
                Button("시간 알림"){
                    MyPageViewModel.instance.scheduleNotification()
                }
                
            }else{
                //Text("버튼을 눌러주세요.")
            }
        }
    }
}
//MARK: - 비밀번호 변경 field
struct PasswordChange: View {
    @ObservedObject var viewUtil: ViewUtil
    @ObservedObject var myPageViewModel = MyPageViewModel()
    
    var body: some View  {
        VStack(alignment: .leading) {
            //현재 비밀번호
            Section(
                header:HStack {
                    Text("현재 비밀번호")
                    RequiredInputLabel()    //필수입력(*) Label
                }) {
                SecureField("", text: $myPageViewModel.currentPassword)
                    .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)    //첫 문자 항상 소문자
                    .keyboardType(.alphabet)    //키보드 타입 - 영문만 표시
                TextFiledUnderLine()    //Text Field 밑줄
            }
            //새 비밀번호
            Section(
                header:HStack {
                    Text("새 비밀번호")
                    RequiredInputLabel()    //필수입력(*) Label
                }) {
                SecureField("5자리 이상 15자리 이하 입력", text: $myPageViewModel.newpassword)
                    .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)    //첫 문자 항상 소문자
                    .keyboardType(.alphabet)    //키보드 타입 - 영문만 표시
                TextFiledUnderLine()    //Text Field 밑줄
            }
            //새 비밀번호 확인
            Section(
                header:HStack {
                    Text("새 비밀번호 확인")
                    RequiredInputLabel()    //필수입력(*) Label
                }) {
                SecureField("5자리 이상 15자리 이하 입력", text: $myPageViewModel.confirmPassword)
                    .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)    //첫 문자 항상 소문자
                    .keyboardType(.alphabet)    //키보드 타입 - 영문만 표시
                TextFiledUnderLine()    //Text Field 밑줄
            }
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
                
                //로그인 실행
                myPageViewModel.signIn() { (result) in
                    viewUtil.isLoading = false  //로딩 종료
                    
                    //로그인 성공이 아닌 경우(현재비밀번호 불일치) Toast 팝업 메시지 호출
                    if result != "success" {
                        viewUtil.showToast = true
                        viewUtil.toastMessage = myPageViewModel.message
                    }
                    //유효성 검사 성공이 아닌 경우 Toast 팝업 메시지 호출
                    else if !myPageViewModel.validate() {
                        viewUtil.showToast = true
                        viewUtil.toastMessage = myPageViewModel.validMessage
                    }
                    //로그인과 유효성 검사 성공일 경우 비밀번호 수정 실행
                    myPageViewModel.passwordChange() { (result) in
                        
                        viewUtil.isLoading = false  //로딩 종료
                        
                        
                        //비밀번호 수정 성공이 아닌 경우 Toast 팝업 메시지 호출
                        if result != "success" {
                            viewUtil.showToast = true
                            viewUtil.toastMessage = myPageViewModel.message
                        }
                        
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

//MARK: - preview
struct MyPageView_Previews: PreviewProvider {
    static var previews: some View {
        MyPageView()
    }
}
