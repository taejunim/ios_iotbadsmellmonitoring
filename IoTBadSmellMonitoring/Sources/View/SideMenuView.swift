//
//  SideMenuView.swift
//  IoTBadSmellMonitoring
//
//  Created by KJ on 2021/07/09.
//

import SwiftUI

struct SideMenuView: View {
    @EnvironmentObject var viewUtil: ViewUtil
    @EnvironmentObject var sideMenuViewModel: SideMenuViewModel
    
    @State var dragOffset = CGSize.zero
    
    var body: some View {
        GeometryReader { geometryReader in
            HStack {
                ZStack {
                    Rectangle()
                        .frame(width: geometryReader.size.width/1.2)
                        .foregroundColor(Color.white)
                    
                    VStack {
                        UserInfoView()
                        
                        VerticalDividerLine()
                        
                        MenuButtonListView(viewUtil: viewUtil, sideMenuViewModel: sideMenuViewModel)
                    
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
                            if gesture.translation.width < 0 {
                                dragOffset.width = gesture.translation.width
                            }
                        }
                        .onEnded { gesture in
                            if gesture.translation.width < -160 {
                                withAnimation {
                                    viewUtil.showMenu.toggle()
                                }
                            }
                            else {
                                dragOffset = .zero
                            }
                        }
                )
                
                VStack {
                    Rectangle()
                        .frame(width: geometryReader.size.width - geometryReader.size.width/1.2)
                        .foregroundColor(.black.opacity(0.001))
                }
                .onTapGesture {
                    withAnimation {
                        viewUtil.showMenu.toggle()
                    }
                }
            }
        }
        .background(Color.black.opacity(0.5))
        .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
    }
}

struct UserInfoView: View {
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text(UserDefaults.standard.string(forKey: "userName") ?? "User Name")
                    .font(.title)
                    .fontWeight(.bold)
                
                Spacer()
            }
            
            HStack {
                Text(UserDefaults.standard.string(forKey: "userId") ?? "User ID")
                    .fontWeight(.bold)
                
                Spacer()
            }
        }
    }
}

struct MenuButtonListView: View {
    @ObservedObject var viewUtil: ViewUtil
    @ObservedObject var sideMenuViewModel: SideMenuViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            //마이페이지 메뉴 버튼
            Button(
                action: {
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
