//
//  LaunchScreen.swift
//  IoTBadSmellMonitoring
//
//  Created by KJ on 2021/06/02.
//

import SwiftUI

//MARK: - Launch Screen
struct LaunchScreen: View {
    @State private var showLaunchScreen = true  //App 실행화면 노출 여부
    
    @State private var half = false //스케일 효과
    @State private var dim = false  //불투명 효과
    @State private var degree = false //흐림 효과
    
    @StateObject private var viewUtil = ViewUtil()
    @StateObject private var weatherViewModel = WeatherViewModel()
    @StateObject private var smellViewModel = SmellReceptionViewModel()
    @StateObject private var sideMenuViewModel = SideMenuViewModel()
    
    //전체 화면 - 그라데이션 효과 설정
    var gradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(
                colors: [
                    Color.black.opacity(0.6),
                    Color.black.opacity(0)
                ]
            ),
            startPoint: .bottom,
            endPoint: .top
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
                }
                .edgesIgnoringSafeArea(.all)    //Safe Area 전체 적용
            }
            else {
                //로그인 정보가 없는 경우, 로그인 화면 이동
                if UserDefaults.standard.string(forKey: "userId") == nil {
                    SignInView()    //로그인 화면 이동
                        .environmentObject(viewUtil)
                }
                //로그인 정보가 있는 경우, 악취 접수 화면 이동
                else {
                    SmellReceptionView()    //악취 접수 화면
                        .environmentObject(viewUtil)
                        .environmentObject(weatherViewModel)
                        .environmentObject(smellViewModel)
                        .environmentObject(sideMenuViewModel)
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
                showLaunchScreen = false    //시작 화면 노출 여부 변경
            }
        }
    }
}

//MARK: - 타이틀 영역
struct Title: View {
    @ObservedObject var viewUtil = ViewUtil()
    
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
                Text("우리동네")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            
            HStack {
                Spacer()
                Text("악취감시")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
                Spacer()
                Spacer()
            }
        }
        .padding()
        .foregroundColor(.white)    //타이틀 색상
        .background(titleGradient)  //타이틀 영역 배경 설정
    }
}

struct LaunchScreen_Previews: PreviewProvider {
    static var previews: some View {
        LaunchScreen()
    }
}
