//
//  ViewUtil.swift
//  IoTBadSmellMonitoring
//
//  Created by KJ on 2021/06/11.
//

import SwiftUI
import Foundation
import ExytePopupView

class ViewUtil: ObservableObject {
    @Published var isLoading: Bool = false    //로딩 화면 노출 여부
    @Published var showToast: Bool = false    //Toast 팝업 노출 여부
    @Published var toastMessage: String = ""    //Toast 팝업 메시지
    @Published var showModal: Bool = false    //Modal 팝업 노출 여부
    @Published var showAlert: Bool = false  //알림창 노출 여부
    @Published var alert: Alert?    //알림창
    @Published var showMenu: Bool = false   //사이드 메뉴 노출 여부
    @Published var isViewDismiss: Bool = false  //창 닫기 여부
    @Published var isBack: Bool = false //뒤로가기 여부
    
    //MARK: - 메뉴 뒤로가기 버튼
    func backMenuButton() -> some View {
        Button(
            action: {
                self.isBack = true  //뒤로가기 여부
            },
            label: {
                HStack {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                }
                .padding(.trailing)
            }
        )
    }

    //MARK: - 로딩 화면
    /// Loading  View Function
    /// - Returns: Loading View
    func loadingView() -> some View {
        ZStack {
            //로딩 화면 색상
            Color(.gray).opacity(0.5)
                .ignoresSafeArea()  //범위 지정
            
            //로딩 Progress View
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color(.darkGray)))
                .scaleEffect(2) //로딩 크기
        }
    }
    
    //MARK: - 조회 로딩 화면
    /// Search Loading  View Function
    /// - Returns: Search Loading View
    func searchLoadingView() -> some View {
        ZStack {
            //로딩 Progress View
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color(.darkGray)))
                .scaleEffect(2) //로딩 크기
        }
    }
    
    //MARK: - Toast 팝업
    /// Toast Popup View
    /// - Returns: Toast Popup View
    func toast() -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(toastMessage)
                .foregroundColor(Color.white)
                .fontWeight(.bold)
        }
        .padding(15)
        .background(Color.black.opacity(0.7))   //배경 색상 및 투명도
        .cornerRadius(10)   //모서리 둥글게 처리
    }

    //MARK: - 키보드 닫기
    /// Dismiss Keyboard
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    //MARK: - 배경 그라데이션 효과
    /// 배경 그라데이션 효과 설정
    /// - Parameters:
    ///   - startColor: 그라데이션 시작 지점 색상
    ///   - endColor: 그라데이션 끝 지점 색상
    ///   - startPoint: 그라데이션 시작 지점 위치
    ///   - endPoint: 그라데이션 끝 지점 위치
    /// - Returns: LinearGradient
    func gradient(_ startColor: String, _ endColor: String, _ startPoint: UnitPoint, _ endPoint: UnitPoint) -> LinearGradient {
        return LinearGradient(
            gradient: Gradient(
                colors: [
                    Color(startColor).opacity(1.0),
                    Color(endColor).opacity(0.6)
                ]
            ),
            startPoint: startPoint,
            endPoint: endPoint
        )
    }
}
