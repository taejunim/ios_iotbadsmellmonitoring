//
//  LaunchScreen.swift
//  IoTBadSmellMonitoring
//
//  Created by KJ on 2021/06/02.
//

import SwiftUI

//MARK: - Launch Screen

struct LaunchScreen: View {
    @ObservedObject var signInViewModel = SignInViewModel() //Sign In View Model
    
    @State private var half: Bool = false //스케일 효과
    @State private var dim: Bool = false  //불투명 효과
    @State private var degree: Bool = false //흐림 효과
    
    @State var showLaunchScreen: Bool = true  //App 실행화면 노출 여부
    
    @StateObject private var viewUtil = ViewUtil()
    @StateObject private var weatherViewModel = WeatherViewModel()
    @StateObject private var smellViewModel = SmellReceptionViewModel()
    @StateObject private var sideMenuViewModel = SideMenuViewModel()
    @StateObject private var noticeViewModel = NoticeViewModel()
    @StateObject private var myPageViewModel = MyPageViewModel()
    @StateObject private var receptionHistoryViewModel = ReceptionHistoryViewModel()
    
    //전체 화면 - 그라데이션 효과 설정
    var gradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(
                colors: [
                    Color.black.opacity(0),
                    Color.black.opacity(0.6)
                ]
            ),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    var body: some View {
        Group {
            //Launch Screen 노출 여부
            if showLaunchScreen {
                ZStack {
                    Rectangle().fill(gradient)  //화면 Gradation 처리

                    //화면 이미지
                    Image("LaunchImage")
                        .resizable()
                        .scaleEffect(half ? 1.0 : 0.5)  //스케일 효과
                        .opacity(dim ? 1.0 : 0.2)   //불투명 효과

                    //타이틀
                    Title()
                        .blur(radius: degree ? 0 : 90)  //타이틀 흐림 효과 처리
                    
                    if signInViewModel.result == "server error" {
                        ServerErrorGuidePopup()
                    }
                    else if signInViewModel.result == "fail" {
                        SignInFailurePopup(showLaunchScreen: $showLaunchScreen)
                    }
                }
                .edgesIgnoringSafeArea(.all)    //Safe Area 전체 적용
            } else {
                //자동 로그인 결과 확인 후 화면 이동
                if signInViewModel.result == "success" {
                    SmellReceptionView()    //악취 접수 화면
                        .environmentObject(viewUtil)
                        .environmentObject(weatherViewModel)
                        .environmentObject(smellViewModel)
                        .environmentObject(sideMenuViewModel)
                        .environmentObject(noticeViewModel)
                        .environmentObject(myPageViewModel)
                        .environmentObject(receptionHistoryViewModel)
                } else {
                    SignInView()    //로그인 화면 이동
                        .environmentObject(viewUtil)
                }
            }
        }
        .onAppear {
            self.half = true

            //시작 화면 Animation 효과 처리
            withAnimation(.easeInOut(duration: 2.0)) {
                self.dim = true
                self.degree = true //흐림 효과 처리 해제
            }
            
            //시작 화면 노출 시간 지연 설정
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                //저장된 로그인 ID 확인
                if UserDefaults.standard.string(forKey: "userId") != nil && UserDefaults.standard.string(forKey: "password") != nil {
                    //자동 로그인 실행
                    signInViewModel.authSignIn() { (result) in
                        if result == "success" {
                            showLaunchScreen = false    //시작 화면 노출 여부 변경
                        }
                    }
                } else {
                    showLaunchScreen = false    //시작 화면 노출 여부 변경
                }
            }
        }
    }
}

//MARK: - 타이틀 영역
struct Title: View {
    //타이틀 Background - 그라데이션 효과 설정
    var titleGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(
                colors: [
                    Color.black.opacity(0.5),
                    Color.black.opacity(0.5)
                ]
            ),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                
                Text("우리동네 악취 모니터링")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
            }
            .padding(.vertical, 10)
        }
        .padding()
        .foregroundColor(.white)    //타이틀 색상
        .background(titleGradient)  //타이틀 영역 배경 설정
    }
}

//MARK: - 서버 오류 안내 팝업
struct ServerErrorGuidePopup: View {
    var body: some View {
        GeometryReader { geometryReader in
            VStack {
                VStack {
                    Text("서버 오류 안내")
                        .fontWeight(.bold)
                    
                    VStack {
                        HorizontalDividerLine()
                        
                        Text("현재 서버와의 통신이 원활하지 않습니다.\n잠시 후 다시 시도 바랍니다.\n문제가 지속되는 경우 관리자에게 문의바랍니다.")
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        HorizontalDividerLine()
                    }
                    .padding(.bottom, 10)
                }
                .padding(.top)
                .background(Color.white)
                .cornerRadius(5.0)
                .frame(maxWidth: .infinity, maxHeight: geometryReader.size.height/3.8)
            }
            .padding()
            .frame(width: geometryReader.size.width, height: geometryReader.size.height)
            .background(Color.black.opacity(0.5))
        }
        .edgesIgnoringSafeArea(.all)
    }
}

//MARK: - 로그인 실패 알림 팝업
struct SignInFailurePopup: View {
    @Binding var showLaunchScreen: Bool
    
    var body: some View {
        GeometryReader { geometryReader in
            VStack {
                VStack {
                    Text("로그인 실패")
                        .fontWeight(.bold)
                    
                    VStack {
                        HorizontalDividerLine()
                        
                        Text("로그인 정보가 일치하지 않아 로그인에 실패하였습니다.\n확인 버튼 클릭 시, 로그인 화면으로 이동합니다.")
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        HorizontalDividerLine()
                        
                        //확인 버튼 - 로그인 화면 이동
                        Button(
                            
                            action: {
                                showLaunchScreen = false //시작 화면 노출 여부 변경
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
                .frame(maxWidth: .infinity, maxHeight: geometryReader.size.height/3.8)
            }
            .padding()
            .frame(width: geometryReader.size.width, height: geometryReader.size.height)
            .background(Color.black.opacity(0.5))
        }
        .edgesIgnoringSafeArea(.all)
    }
}


struct LaunchScreen_Previews: PreviewProvider {
    static var previews: some View {
        LaunchScreen()
    }
}
