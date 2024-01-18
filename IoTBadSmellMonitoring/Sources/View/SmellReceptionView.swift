//
//  SmellReceptionView.swift
//  IoTBadSmellMonitoring
//
//  Created by KJ on 2021/06/18.
//

import SwiftUI
import UIKit

//MARK: - 악취 접수 화면

struct SmellReceptionView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.scenePhase) var scenePhase
    @ObservedObject var signInViewModel = SignInViewModel() //Sign In View Model
    
    @State var isSignIn: Bool = true  //App 실행화면 노출 여부
    @State var showLaunchScreen: Bool = true  //App 실행화면 노출 여부
    
    @EnvironmentObject var viewUtil: ViewUtil   //화면 Util
    @ObservedObject var viewOptionSet = ViewOptionSet() //화면 Option Set
    @ObservedObject var codeViewModel = CodeViewModel() //Code View Model
    @EnvironmentObject var weatherViewModel: WeatherViewModel //Weather View Model
    @EnvironmentObject var smellViewModel: SmellReceptionViewModel  //Smell Reception View Model
    @EnvironmentObject var sideMenuViewModel: SideMenuViewModel //Side Menu View Model
    @EnvironmentObject var noticeViewModel: NoticeViewModel //Notice View Model
    @EnvironmentObject var myPageViewModel: MyPageViewModel //My Page View Model
    @EnvironmentObject var receptionHistory: ReceptionHistoryViewModel  //Reception History View Model

    var body: some View {
        
        
    //로그아웃 여부에 따라 로그인 화면 이동
    if sideMenuViewModel.isSignOut {
        let _ = print("로그아웃하고 여기로 이동?")
        //로그인 화면
        SignInView()
            .environmentObject(viewUtil)
    }
    else {
        if !UserDefaults.standard.bool(forKey: "isSignIn") {
//        SignInView().environmentObject(viewUtil)
            SignInFailurePopupInPage()
        } else {
                //사이드 메뉴 선택 시, 해당 메뉴로 이동 - My Page
                if sideMenuViewModel.moveMenu == "MyPage" {
                    MyPageView()
                        .environmentObject(viewUtil)
                }
                //사이드 메뉴 선택 시, 해당 메뉴로 이동 - 접수 이력
                else if sideMenuViewModel.moveMenu == "ReceptionHistory" {
                    ReceptionHistoryView()
                        .environmentObject(viewUtil)
                }
                //악취 접수 메인 화면
                else {
                    ZStack {
                        //공지사항 오늘 하루 보지 않기 처리 여부에 따른 공지사항 팝업 표출
                        if !noticeViewModel.isCloseToday {
                            if !noticeViewModel.isClose {
                                //공지사항 팝업
                                NoticePopupView(noticeViewModel: noticeViewModel)
                                    .zIndex(1)
                            }
                        }
                        
                        //로딩 표시 여부에 따라 표출
                        if viewUtil.isLoading {
                            viewUtil.loadingView()  //로딩 화면
                                .zIndex(1)  //Z Stack 순서 맨 앞으로
                        }
                        
                        //사이드 메뉴
                        if viewUtil.showMenu {
                            SideMenuView()
                                .environmentObject(viewUtil)
                                .environmentObject(sideMenuViewModel)
                                .zIndex(1)
                        }
                        
                        //악취 접수 메인 화면
                        NavigationView {
                            VStack {
                                ScrollView {
                                    CurrentWeatherView(viewUtil: viewUtil, weatherViewModel: weatherViewModel, smellViewModel: smellViewModel)  //현재 날씨 화면
                                    
                                    SmellReceptionBanner(smellViewModel: smellViewModel) //악취 접수 배너 - 접수 현황 및 통계

                                    SmellLevelView(weatherViewModel: weatherViewModel, smellViewModel: smellViewModel)  //악취 강도 선택 화면
                                    
                                    DividerLine()   //구분선
                                }
                            }
                            .disabled(viewUtil.isLoading)   //로딩 중 화면 클릭 방지
                            .navigationBarTitle(Text("악취 접수"), displayMode: .inline) //Navigation Bar 타이틀
                            .navigationBarBackButtonHidden(true)    //기본 Back 버튼 숨김
                            .navigationBarItems(leading: MenuButton(viewUtil: viewUtil))  //커스텀 Back 버튼 추가
                        }
                        .navigationBarBackButtonHidden(true)
                    }
                    .onAppear {
                        viewUtil.isLoading = true   //로딩 시작
                        
                        smellViewModel.setRegionInfo()  //사용자의 지역 정보 세팅
                        
                        smellViewModel.weatherBackground = smellViewModel.setWeatherBackground()    //시간에 따른 날씨 배경 설정
                        smellViewModel.getSmellCode()   //악취 강도 코드
                        smellViewModel.getReceptionStatus() //금일 냄새 접수 현황
                        smellViewModel.getRegionalStatistics()  //사용자 지역의 악취 접수 통계
                        
                        //현재 날씨 호출
                        weatherViewModel.getCurrentWeather() { (gridResult, weather) in
                            //지역 격자 정보 호출 결과가 실패하거나 오류인 경우 처리
                            if gridResult == "fail" {
                                smellViewModel.topRegionName = "제주도"
                            } else if gridResult == "error" {
                                smellViewModel.topRegionName = "-"
                            }
                            
                            weatherViewModel.currentWeather = weather   //현재 날씨 정보
                            viewUtil.isLoading = false  //로딩 종료
                        }
                        
                        noticeViewModel.checkCloseToday()   //공지사항 오늘 하루 보지 않기 처리 확인
                    }
                    .onChange(of: viewUtil.isViewDismiss, perform: { _ in
                        //isViewDismiss가 true인 경우만 실행 - 냄새 접수 등록 완료 후 재호출
                        if viewUtil.isViewDismiss {
                            viewUtil.isLoading = true   //로딩 시작
                            
                            smellViewModel.weatherBackground = smellViewModel.setWeatherBackground()    //시간에 따른 날씨 배경 설정
                            smellViewModel.getSmellCode()   //악취 강도 코드
                            smellViewModel.getReceptionStatus() //금일 냄새 접수 현황
                            smellViewModel.getRegionalStatistics()  //사용자 지역의 악취 접수 통계
                            
                            //현재 날씨 호출
                            weatherViewModel.getCurrentWeather() { (gridResult, weather) in
                                //지역 격자 정보 호출 결과가 실패하거나 오류인 경우 처리
                                if gridResult == "fail" {
                                    smellViewModel.topRegionName = "제주도"
                                } else if gridResult == "error" {
                                    smellViewModel.topRegionName = "-"
                                }
                                
                                weatherViewModel.currentWeather = weather   //현재 날씨 정보
                                viewUtil.isLoading = false  //로딩 종료
                            }
                            
                            //공지사항 - 하루 동안 보지 않기 설정이 아닌 경우
                            if !noticeViewModel.isCloseToday {
                                noticeViewModel.isClose = false
                            }
                        }
                        
                        viewUtil.isViewDismiss = false
                })
                    .onChange(of: scenePhase) { newPahase in
                        if newPahase == .active {
                            signInViewModel.authSignIn() {result in
                                if result != "success" {
                                    UserDefaults.standard.set(false, forKey: "isSignIn")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}


//MARK: - Menu 버튼
struct MenuButton: View {
    @ObservedObject var viewUtil: ViewUtil
    
    var body: some View {
        Button(
            action: {
                withAnimation {
                    viewUtil.showMenu.toggle()
                }
            },
            label: {
                HStack {
                    Image("Menu.Icon")
                        .renderingMode(.template)
                        .resizable()
                        .foregroundColor(.black)
                        .frame(width: 35, height: 35, alignment: .leading)
                }
                .padding(.trailing)
            }
        )
    }
}

//MARK: - 현재 날씨 정보
struct CurrentWeatherView: View {
    @ObservedObject var viewUtil: ViewUtil
    
    @ObservedObject var weatherViewModel: WeatherViewModel //Weather View Model
    @ObservedObject var smellViewModel: SmellReceptionViewModel //Smell Reception View Model

    @State private var isRefresh: Bool = false  //새로고침 여부
    
    var body: some View {
        VStack {
            //현재 날씨 타이틀 및 새로고침 버튼
            ZStack {
                Text("\(smellViewModel.topRegionName) 현재 날씨")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.bottom, 5)

                HStack {
                    Spacer()
                    
                    //새로고침 버튼
                    Button(
                        action: {
                            isRefresh = true    //새로고침 활성
                            
                            //현재 날씨 호출
                            weatherViewModel.getCurrentWeather() { (gridResult, weather) in
                                //지역 격자 정보 호출 결과가 실패하거나 오류인 경우 처리
                                if gridResult == "fail" {
                                    smellViewModel.topRegionName = "제주도"
                                } else if gridResult == "error" {
                                    smellViewModel.topRegionName = "-"
                                }
                                
                                weatherViewModel.currentWeather = weather   //현재 날씨 정보
                                
                                isRefresh = false   //새로고침 비활성
                            }
                        },
                        label: {
                            ZStack {
                                //새로고침 여부에 따라 화면 출력
                                if isRefresh {
                                    //버튼 로딩 화면
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: Color(.white)))
                                        .scaleEffect(1) //로딩 크기
                                }
                                else {
                                    //새로고침 버튼
                                    Image("Refresh.Icon")
                                        .renderingMode(.template)
                                        .resizable()
                                        .foregroundColor(.white)
                                        .frame(width: 25, height: 25)
                                }
                            }
                            .padding(.horizontal)
                        }
                    )
                }
            }

            //현재 날씨 정보
            HStack {
                Spacer()
                
                //날씨 API 호출 성공 시, 현재 날씨 정보
                if weatherViewModel.result == "success" {
                    //날씨 아이콘 - 기존
//                    Group {
//                        Image(systemName: "cloud.sun.fill")
//                            .renderingMode(.original)
//                            .font(Font.system(size: 70))
//                            .border(Color.black)
//                    }
                    //날씨 아이콘 - 변경
                    Image(weatherViewModel.currentWeather["weatherIcon"] ?? "Sun")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 110, height: 90)
                    
                    Spacer()

                    VStack(alignment: .leading, spacing: 20) {
                        //기온
                        Text("기온 : \(weatherViewModel.currentWeather["temp"] ?? "0")℃")
                            .fontWeight(.bold)
                        //풍향
                        Text("풍향 : \(weatherViewModel.currentWeather["windDirection"] ?? "0")")
                            .fontWeight(.bold)
                    }

                    Spacer()

                    VStack(alignment: .leading, spacing: 20) {
                        //습도
                        Text("습도 : \(weatherViewModel.currentWeather["humidity"] ?? "0")%")
                            .fontWeight(.bold)
                        //풍속
                        Text("풍속 : \(weatherViewModel.currentWeather["windSpeed"] ?? "0")m/s")
                            .fontWeight(.bold)
                    }
                }
                //날씨 API 호출 실패 시, 메세지 출력
                else {
                    VStack(alignment: .center) {
                        Text(weatherViewModel.message)
                            .fontWeight(.bold)
                    }
                    .padding(.vertical, 30)
                }
                
                Spacer()
            }
            .foregroundColor(.white)
        }
        .padding(.vertical, 10)
        .background(viewUtil.gradient(smellViewModel.weatherBackground.0, smellViewModel.weatherBackground.1, .top, .bottom))   //현재 날씨 화면 배경 설정
    }
}

//MARK: - 악취 접수 배너
struct SmellReceptionBanner: View {
    @ObservedObject var smellViewModel: SmellReceptionViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            DividerLine()
            
            TabView {
                VStack {
                    ReceptionStatusView(smellViewModel: smellViewModel) //금일 접수 현황 화면

                    Spacer()
                }
                
                VStack {
                    RegionalStatisticsView(smellViewModel: smellViewModel)  //사용자 지역의 통계 화면
                    
                    Spacer()
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .frame(height: 160)
            .padding(.top, 10)
            .onAppear {
                UIPageControl.appearance().currentPageIndicatorTintColor = .black   //현재 페이지 Indicator 색상
                UIPageControl.appearance().pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.2)   //페이지 Indicator 색상
            }
            
            Divider()
                .frame(height: 1)
                .background(Color("Color_EFEFEF"))
                .padding([.leading, .bottom, .trailing], 10)
        }
    }
}

//MARK: - 금일 접수 현황 화면
struct ReceptionStatusView: View {
    @ObservedObject var smellViewModel: SmellReceptionViewModel
    
    var body: some View {
        VStack {
            HStack(spacing: 3) {
                Text("금일 악취 접수 현황")
                    .font(.subheadline)
                    .fontWeight(.bold)
                
                //금일 접수 횟수
                Text("(\(smellViewModel.completeCount)/\(smellViewModel.receptionStatus.count))")
                    .font(.footnote)
                    .fontWeight(.bold)
                
                Spacer()
            }
            
            HStack {
                //금일 냄새 접수 현황
                ForEach(smellViewModel.receptionStatus, id: \.self) { status in
                    //let timeZoneCode: String = status["timeZoneCode"] ?? ""   //접수 시간대 코드
                    let timeZone: String = status["timeZone"] ?? "" //접수 시간대
                    let statusCode: String = status["statusCode"] ?? "" //접수상태 코드
                    
                    //접수상태에 따른 이미지 명
                    let statusImage: String = {
                        //접수 완료
                        if statusCode == "001" {
                            return "Check.Circle"
                        }
                        //접수 미완료
                        else if statusCode == "002" {
                            return "Xmark.Circle"
                        }
                        //접수 예정
                        else {
                            return "Minus.Circle"
                        }
                    }()
                    
                    VStack {
                        //접수 상태 이미지
                        Image(statusImage)
                            .resizable().scaledToFill().frame(width: 60, height: 60).clipped()
                        //접수 시간대
                        Text(timeZone)
                            .font(.caption)
                    }
                    
                    //마지막 접수 현황 Spacer() 제외 처리
                    if status != smellViewModel.receptionStatus.last {
                        Spacer()
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

//MARK: - 사용자 지역의 접수 통계 화면
struct RegionalStatisticsView: View {
    @ObservedObject var smellViewModel: SmellReceptionViewModel
    
    var body: some View {
        VStack {
            HStack(spacing: 3) {
                Text("우리동네 악취 현황")
                    .font(.subheadline)
                    .fontWeight(.bold)
                
                HStack(spacing: 0) {
                    Text("(총 악취 접수 : ")
                        .font(.footnote)
                        .fontWeight(.bold)
                    
                    Text("\(smellViewModel.receptionTotalCount)")
                        .font(.footnote)
                        .fontWeight(.bold)
                        .foregroundColor(Color("Color_E74C3C"))
                    
                    Text(" 건)")
                        .font(.footnote)
                        .fontWeight(.bold)
                }
                
                Spacer()
            }
            
            HStack(spacing: 0) {
                VStack {
                    Text("감지 횟수")
                        .fontWeight(.bold)
                        .foregroundColor(Color("Color_006AC5"))
                        .frame(height: 50)
                    
                    Text("\(smellViewModel.detectionCount) 건")
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                VStack {
                    Text("감지 비율")
                        .fontWeight(.bold)
                        .foregroundColor(Color("Color_006AC5"))
                        .frame(height: 50)
                    
                    Text("\(String(smellViewModel.detectionRate)) %")
                    //Text("\(String(format: "%.2f", smellViewModel.detectionRate)) %") //소수점 2자리
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                VStack {
                    Text("주요 감지 악취 강도")
                        .fontWeight(.bold)
                        .foregroundColor(Color("Color_006AC5"))
                        .frame(height: 50)
                    
                    Text("\(smellViewModel.mainSmellLevelName)")
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                VStack {
                    Text("주요 악취")
                        .fontWeight(.bold)
                        .foregroundColor(Color("Color_006AC5"))
                        .frame(height: 50)
                    
                    Text("\(smellViewModel.mainSmellTypeName)")
                        .fontWeight(.bold)
                }
            }
            .font(.subheadline)
            
            Spacer()
        }
        .padding(.horizontal)
    }
}

//MARK: - 악취 강도 선택 화면

struct SmellLevelView: View {
    @ObservedObject var weatherViewModel: WeatherViewModel
    @ObservedObject var smellViewModel: SmellReceptionViewModel
    
    var body: some View {
        VStack {
            HStack {
                Text("악취 강도를 선택하세요.")
                    .fontWeight(.bold)
            }

            //악취 강도 선택 버튼 생성
            ForEach(smellViewModel.smellCode, id: \.self) { code in
                let smellCode: String = code["code"] ?? ""  //코드
                let smellName: String = code["codeName"] ?? ""  //코드 명
                let smellComment: String = code["codeComment"] ?? ""    //코드 설명

                //악취 강도 선택 버튼 색상
                let smellColor: String = {
                    switch smellCode {
                    case "001":
                        return "Zero.Degree"
                    case "002":
                        return "One.Degree"
                    case "003":
                        return "Two.Degree"
                    case "004":
                        return "Three.Degree"
                    case "005":
                        return "Four.Degree"
                    case "006":
                        return "Five.Degree"
                    default:
                        return "Color_FFFFFF"
                    }
                }()

                //악취 강도 선택 버튼
                NavigationLink(
                    destination:
                        ReceptionRegistView(selectSmell: code),   //악취 접수 등록 화면 - 선택한 악취 강도 정보 전달
                    label: {
                        //악취 강도 - 악취 설명
                        Text("\(smellName) - \(smellComment)")
                            .fontWeight(.bold)
                            .foregroundColor(Color.white)
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: 35, alignment: .leading)
                            .background(Color(smellColor))
                            .cornerRadius(10.0)
                    }
                )
                .padding(.horizontal)
            }
        }
    }
}


struct SmellReceptionView_Previews: PreviewProvider {
    static var previews: some View {
        SmellReceptionView()
            .environmentObject(ViewUtil())
            .environmentObject(WeatherViewModel())
            .environmentObject(SmellReceptionViewModel())
            .environmentObject(SideMenuViewModel())
            .environmentObject(NoticeViewModel())
    }
}
