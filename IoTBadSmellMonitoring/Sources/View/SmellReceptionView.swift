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
    
    @EnvironmentObject var viewUtil: ViewUtil   //화면 Util
    @ObservedObject var viewOptionSet = ViewOptionSet() //화면 Option Set
    @ObservedObject var codeViewModel = CodeViewModel() //Code View Model
    @EnvironmentObject var weatherViewModel: WeatherViewModel //Weather View Model
    @EnvironmentObject var smellViewModel: SmellReceptionViewModel  //Smell Reception View Model
    @EnvironmentObject var sideMenuViewModel: SideMenuViewModel //Side Menu View Model

    var body: some View {
        //로그아웃 여부에 따라 로그인 화면 이동
        if sideMenuViewModel.isSignOut {
            //로그인 화면
            SignInView()
                .environmentObject(viewUtil)
        }
        else {
            ZStack {
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
                        //.transition(.move(edge: .leading))
                }
                
                //악취 접수 메인 화면
                NavigationView {
                    VStack {
                        ScrollView {
                            CurrentWeatherView(viewUtil: viewUtil, weatherViewModel: weatherViewModel, smellViewModel: smellViewModel)  //현재 날씨 화면
                            
                            DividerLine()   //구분선
                            ReceptionStatusView(smellViewModel: smellViewModel) //금일 접수 현황 화면
                            
                            DividerLine()   //구분선

                            SmellLevelView(weatherViewModel: weatherViewModel, smellViewModel: smellViewModel)  //악취 강도 선택 화면
                            
                            DividerLine()   //구분선
                        }
                    }
                    .disabled(viewUtil.isLoading)   //로딩 중 화면 클릭 방지
                    .navigationBarTitle(Text("악취 접수"), displayMode: .inline) //Navigation Bar 타이틀
                    .navigationBarBackButtonHidden(true)    //기본 Back 버튼 숨김
                    .navigationBarItems(leading: MenuButton(viewUtil: viewUtil))  //커스텀 Back 버튼 추가
                }
            }
            .onAppear {
                viewUtil.isLoading = true   //로딩 시작
                
                smellViewModel.weatherBackground = smellViewModel.setWeatherBackground()    //시간에 따른 날씨 배경 설정
                smellViewModel.getSmellCode()   //악취 강도 코드
                smellViewModel.getReceptionStatus() //금일 냄새 접수 현황
                
                //현재 날씨 호출
                weatherViewModel.getCurrentWeather() { (weather) in
                    weatherViewModel.currentWeather = weather   //현재 날씨 정보
                    viewUtil.isLoading = false  //로딩 종료
                }
            }
            .onChange(of: viewUtil.isViewDismiss, perform: { _ in
                //isViewDismiss가 true인 경우만 실행 - 냄새 접수 등록 완료 후 재호출
                if viewUtil.isViewDismiss {
                    viewUtil.isLoading = true   //로딩 시작
                    
                    smellViewModel.weatherBackground = smellViewModel.setWeatherBackground()    //시간에 따른 날씨 배경 설정
                    smellViewModel.getSmellCode()   //악취 강도 코드
                    smellViewModel.getReceptionStatus() //금일 냄새 접수 현황
                    
                    //현재 날씨 호출
                    weatherViewModel.getCurrentWeather() { (weather) in
                        weatherViewModel.currentWeather = weather   //현재 날씨 정보
                        viewUtil.isLoading = false  //로딩 종료
                    }
                }
                
                viewUtil.isViewDismiss = false
            })
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
                    Image(systemName: "line.horizontal.3")
                        .foregroundColor(.black)
                        .font(Font.system(size: 25, weight: .bold))
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

    var body: some View {
        VStack {
            Text("현재 날씨")
                .font(.title3)
                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                .foregroundColor(.white)
                .padding(.bottom, 5)

            HStack {
                Spacer()
                
                //날씨 API 호출 성공 시
                if weatherViewModel.result == "success" {
                    Group {
                        Image(systemName: weatherViewModel.currentWeather["weatherIcon"] ?? "sun.max.fill")
                            .renderingMode(.original)
                            .font(Font.system(size: 70))
                    }

                    Spacer()

                    VStack(alignment: .leading, spacing: 20) {
                        Text("기온 : \(weatherViewModel.currentWeather["temp"] ?? "0")℃")
                            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        Text("풍향 : \(weatherViewModel.currentWeather["windDirection"] ?? "0")")
                            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    }

                    Spacer()

                    VStack(alignment: .leading, spacing: 20) {
                        Text("습도 : \(weatherViewModel.currentWeather["humidity"] ?? "0")%")
                            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        Text("풍속 : \(weatherViewModel.currentWeather["windSpeed"] ?? "0")m/s")
                            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    }
                }
                //날씨 API 호출 실패 시
                else {
                    VStack(alignment: .center) {
                        Text(weatherViewModel.message)
                            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
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

//MARK: - 금일 접수 현황 화면
struct ReceptionStatusView: View {
    @ObservedObject var smellViewModel: SmellReceptionViewModel
    
    var body: some View {
        VStack {
            HStack {
                Text("금일 냄새 접수 현황(\(smellViewModel.completeCount)/\(smellViewModel.receptionStatus.count))")
                    .font(/*@START_MENU_TOKEN@*/.subheadline/*@END_MENU_TOKEN@*/)
                
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
                        Image(statusImage)
                            .resizable().scaledToFill().frame(width: 60, height: 60).clipped()

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

//MARK: - 악취 강도 선택 화면
struct SmellLevelView: View {
    @ObservedObject var weatherViewModel: WeatherViewModel
    @ObservedObject var smellViewModel: SmellReceptionViewModel
    
    var body: some View {
        VStack {
            HStack {
                Text("악취 강도를 선택하세요.")
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
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
                        ReceptionRegistView(selectSmell: code).environmentObject(ViewUtil()),   //악취 접수 등록 화면 - 선택한 악취 강도 정보 전달
                    label: {
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
    }
}
