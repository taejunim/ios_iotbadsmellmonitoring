//
//  SmellReceptionView.swift
//  IoTBadSmellMonitoring
//
//  Created by KJ on 2021/06/18.
//

import SwiftUI

//MARK: - 냄새 접수 화면
struct SmellReceptionView: View {
    @State private var viewOptionSet = ViewOptionSet() //화면 Option Set
    
    @ObservedObject var viewUtil = ViewUtil()
    @ObservedObject var codeViewModel = CodeViewModel() 
    @ObservedObject var weatherViewModel = WeatherViewModel() //Weather View Model
    @ObservedObject var smellViewModel = SmellReceptionViewModel() //Smell Reception View Model
    
    init() {
        viewOptionSet.navigationBarOption() //Navigation Bar 옵션
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                //로딩 표시 여부에 따라 표출
                if viewUtil.isLoading {
                    viewUtil.loadingView()  //로딩 화면
                        .zIndex(1)  //Z Stack 순서 맨 앞으로
                }
                
                VStack {
                    ScrollView {
                        CurrentWeatherView(viewUtil: viewUtil, smellViewModel: smellViewModel)
                        DividerLine()
                        ReceptionStatusView()
                        DividerLine()
                        SmellLevelView(smellViewModel: smellViewModel)
                        DividerLine()
                    }
                }
                .disabled(viewUtil.isLoading)   //로딩 중 화면 클릭 방지
            }
            .navigationBarTitle(Text("냄새 접수"), displayMode: .inline) //Navigation Bar 타이틀
            .navigationBarBackButtonHidden(true)    //기본 Back 버튼 숨김
            .navigationBarItems(leading: MenuButton())  //커스텀 Back 버튼 추가
        }
        .onAppear {
            viewUtil.isLoading = true
            
            smellViewModel.weatherBackground = smellViewModel.setWeatherBackground()
            
            smellViewModel.getSmellCode()   //악취 강도 코드
            
            weatherViewModel.getCurrentWeather() { (weather) in
                weatherViewModel.currentWeather = weather
                viewUtil.isLoading = false
            }
        }
    }
}

//MARK: - Menu 버튼
struct MenuButton: View {
    var body: some View {
        Button(
            action: {
                
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
                        Text("날씨 정보를 불러오지 못하였습니다.")
                            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    }
                    .padding(.vertical, 30)
                    
                }
                
                Spacer()
            }
            .foregroundColor(.white)
        }
        .padding(.vertical, 10)
        .background(viewUtil.gradient(smellViewModel.weatherBackground.0, smellViewModel.weatherBackground.1, .top, .bottom))
    }
}

//MARK: - 금일 접수 현황 화면
struct ReceptionStatusView: View {
    @State var count: Int = 2
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("금일 냄새 접수 현황(\(count)/4)")
                    .font(/*@START_MENU_TOKEN@*/.subheadline/*@END_MENU_TOKEN@*/)
                Spacer()
            }
            
            HStack {
                VStack {
                    Image("Check.Circle")
                        .resizable().scaledToFill().frame(width: 60, height: 60).clipped()
                    
                    Text("07:00 ~ 09:00")
                        .font(.caption)
                }
                
                Spacer()
                
                VStack {
                    Image("Xmark.Circle")
                        .resizable().scaledToFill().frame(width: 60, height: 60).clipped()
                    
                    Text("12:00 ~ 14:00")
                        .font(.caption)
                }
                
                Spacer()
                
                VStack {
                    Image("Check.Circle")
                        .resizable().scaledToFill().frame(width: 60, height: 60).clipped()
                    
                    Text("18:00 ~ 20:00")
                        .font(.caption)
                }
                
                Spacer()
                
                VStack {
                    Image("Minus.Circle")
                        .resizable().scaledToFill().frame(width: 60, height: 60).clipped()
                    
                    Text("22:00 ~ 00:00")
                        .font(.caption)
                }
            }
        }
        .padding(.horizontal)
    }
}

//MARK: - 악취 강도 선택 화면
struct SmellLevelView: View {
    @ObservedObject var smellViewModel: SmellReceptionViewModel

    var body: some View {
        VStack {
            HStack {
                Text("악취 강도를 선택하세요.")
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
            }

            //악취 강도 선택 버튼 생성
            ForEach(smellViewModel.smellCode, id: \.self) { smellCode in
                let codeName: String = smellCode["codeName"] ?? ""  //코드 명
                let codeComment: String = smellCode["codeComment"] ?? ""    //코드 설명

                //악취 강도 선택 버튼 색상
                let smellColor: String = {
                    switch smellCode["code"] ?? "" {
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
                        return "Color_ FFFFFF"
                    }
                }()

                //악취 강도 선택 버튼
                NavigationLink(
                    destination: SignUpView(),
                    label: {
                        Text("\(codeName) - \(codeComment)")
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
    }
}
