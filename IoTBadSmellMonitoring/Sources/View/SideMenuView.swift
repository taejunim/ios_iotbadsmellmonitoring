//
//  SideMenuView.swift
//  IoTBadSmellMonitoring
//
//  Created by KJ on 2021/07/09.
//

import SwiftUI

//MARK: - 사이드 메뉴 화면
struct SideMenuView: View {
    @EnvironmentObject var viewUtil: ViewUtil   //View Util
    @EnvironmentObject var sideMenuViewModel: SideMenuViewModel //Side Menu View Model
    
    @State var dragOffset = CGSize.zero //Drag Offset
    
    var body: some View {
        GeometryReader { geometryReader in
            HStack {
                ZStack {
                    Rectangle()
                        .frame(width: geometryReader.size.width/1.2)
                        .foregroundColor(Color.white)
                    
                    VStack {
                        UserInfoView()  //사용자 정보
                        
                        VerticalDividerLine()
                        
                        MenuButtonListView(viewUtil: viewUtil, sideMenuViewModel: sideMenuViewModel)    //메뉴 버튼 목록
                    
                        Spacer()
                    }
                    .padding(.horizontal)
                    .frame(width: geometryReader.size.width/1.2, height: geometryReader.size.height/1.2)
                }
                .transition(.move(edge: .leading))
                .offset(dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            //사이드 메뉴 영역 좌우 드래그 시, 사이드 메뉴 이동
                            if gesture.translation.width < 0 {
                                dragOffset.width = gesture.translation.width
                            }
                        }
                        .onEnded { gesture in
                            //사이드 메뉴 좌측으로 드래그 시, 이동한 넓이가 -160 이하인 경우 사이드 메뉴 닫기
                            if gesture.translation.width < -160 {
                                withAnimation {
                                    viewUtil.showMenu.toggle()
                                }
                            }
                            //사이드 메뉴 제자리 위치로 초기화
                            else {
                                dragOffset = .zero
                            }
                        }
                )
                
                //사이드 메뉴 우측 불투명 영역
                VStack {
                    Rectangle()
                        .frame(width: geometryReader.size.width - geometryReader.size.width/1.2)
                        .foregroundColor(.black.opacity(0.001))
                }
                .onTapGesture {
                    withAnimation {
                        viewUtil.showMenu.toggle()  //사이드 메뉴 닫기
                    }
                }
            }
        } 
        .background(Color.black.opacity(0.5))
        .edgesIgnoringSafeArea(.all)
    }
}

//MARK: 사용자 정보 화면
struct UserInfoView: View {
    var body: some View {
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

//MARK: - 메뉴 버튼 목록 화면
struct MenuButtonListView: View {
    @ObservedObject var viewUtil: ViewUtil
    @ObservedObject var sideMenuViewModel: SideMenuViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            //마이페이지 메뉴 버튼
            Button(
                action: {
                    withAnimation {
                        sideMenuViewModel.moveMenu = "MyPage"   //이동할 메뉴 - My Page
                    }
                },
                label: {
                    HStack {
                        Text("My Page")
                            .foregroundColor(Color.black)
                            
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: 35)
                }
            )
            
            //악취 접수 이력 메뉴 버튼
            Button(
                action: {
                    withAnimation {
                        sideMenuViewModel.moveMenu = "ReceptionHistory" //이동할 메뉴 - 접수 이력
                    }
                },
                label: {
                    HStack {
                        Text("악취 접수 이력")
                            .foregroundColor(Color.black)
                            
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: 35)
                }
            )
            
            //로그아웃 버튼
            Button(
                action: {
                    sideMenuViewModel.showAlert = true  //알람 노출 여부
                    sideMenuViewModel.alert = sideMenuViewModel.signOutAlert()  //알람 생성
                },
                label: {
                    HStack {
                        Text("로그아웃")
                            .foregroundColor(Color.black)
                            
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: 35)
                }
            )
            .alert(isPresented: $sideMenuViewModel.showAlert) {
                sideMenuViewModel.alert! //알림창 호출
            }
        }
    }
}

struct SideMenuView_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuView()
            .environmentObject(ViewUtil())
            .environmentObject(SideMenuViewModel())
    }
}
