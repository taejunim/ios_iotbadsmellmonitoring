//
//  NoticeView.swift
//  IoTBadSmellMonitoring
//
//  Created by KJ on 2022/03/18.
//

import SwiftUI

//MARK: - 공지사항 화면
struct NoticeView: View {
    @ObservedObject var noticeViewModel = NoticeViewModel() //공지사항 View Model
    
    var body: some View {
        VStack {
            NoticeContentView(noticeViewModel: noticeViewModel) //공지사항 내용
        }
    }
}

//MARK: - 공지사항 내용 화면
struct NoticeContentView: View {
    @ObservedObject var noticeViewModel: NoticeViewModel
    
    var body: some View {
        VStack {
            HorizontalDividerLine()
            
            //공지사항 제목
            HStack {
                Text("\(noticeViewModel.noticeTitle)")
                    .font(.headline)
                
                Spacer()
            }
            .padding(.horizontal, 15)
            
            HorizontalDividerLine()
            
            //공지사항 내용
            HStack {
                Text("\(noticeViewModel.noticeContent)")
                    .font(.subheadline)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .padding(.horizontal, 15)
            
            Spacer()
            
            HorizontalDividerLine()
        }
    }
}

//MARK: - 공지사항 팝업 화면
struct NoticePopupView: View {
    @ObservedObject var noticeViewModel: NoticeViewModel
    
    var body: some View {
        GeometryReader { geometryReader in
            VStack {
                VStack {
                    Text("공지 사항")
                        .fontWeight(.bold)
                    
                    VStack(spacing: 0) {
                        NoticeContentView(noticeViewModel: noticeViewModel) //공지사항 제목
                        
                        NoticePopupButton(noticeViewModel: noticeViewModel) //공지사항 내용
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
        .onAppear {
            noticeViewModel.getNotice() //공지사항 호출
        }
    }
}

//MARK: - 공지사항 팝업 버튼
struct NoticePopupButton: View {
    @ObservedObject var noticeViewModel: NoticeViewModel
    
    var body: some View {
        HStack {
            //오늘 하루 동안 보지 않기 버튼 - 창딛기
            Button(
                action: {
                    noticeViewModel.closeToday()    //오늘 하루 동안 보지 않기 실행
                },
                label: {
                    HStack(spacing: 5) {
                        Spacer()
                        
                        Text("오늘 하루 동안 보지 않기")
                            .fontWeight(.bold)
                            .fixedSize(horizontal: true, vertical: false)
                        
                        Spacer()
                        
                        Image(systemName: "xmark")
                    }
                    .foregroundColor(Color.white)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, maxHeight: 30)
                    .background(Color("Color_5E5E5E"))
                    .cornerRadius(5)
                    .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
                }
            )
            .padding(10)
            
            Spacer().frame(width: 0)
            
            //확인 버튼 - 창닫기
            Button(
                action: {
                    noticeViewModel.isClose = true
                },
                label: {
                    Text("확인")
                        .fontWeight(.bold)
                        .foregroundColor(Color.white)
                        .padding(.horizontal)
                        .frame(maxHeight: 30)
                        .background(Color("Color_3498DB"))
                        .cornerRadius(5)
                        .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
                }
            )
            .padding(10)
        }
    }
}

struct NoticeView_Previews: PreviewProvider {
    static var previews: some View {
        NoticePopupView(noticeViewModel: NoticeViewModel())
    }
}
