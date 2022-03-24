//
//  Location.swift
//  IoTBadSmellMonitoring
//
//  Created by KJ on 2021/07/05.
//

import SwiftUI
import Foundation
import CoreLocation

class Location: ObservableObject {
    private let viewUtil = ViewUtil()
    
    @Published var locationManager = CLLocationManager()    //Location Manager 인스턴스 생성
    @Published var latitude: Double?    //위도
    @Published var longitude: Double?   //경도
    @Published var status: String?  //위치 서비스 권한 상태
    @Published var showAlert: Bool = false  //알림창 노출 여부
    @Published var alert: Alert?    //알림창
    
    init() {
        self.locationManager.requestWhenInUseAuthorization()    //위치정보 권한 요청
        self.locationManager.allowsBackgroundLocationUpdates = true //Background 위치 업데이트 허용
    }
    
    //MARK: - 위치 서비스 시작
    func startLocation() {
        self.locationManager.requestWhenInUseAuthorization()    //위치정보 권한 요청
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest  //배터리에 권장되는 최적의 정확도
        self.locationManager.startUpdatingLocation()    //위치정보 업데이트

        getLocation()   //위치 정보 호출
    }
    
    //MARK: - 위치 서비스 권한 상태
    /// 사용자의 현재 위치 서비스에 대한 권한 상태를 String 형태로 제공
    /// - Returns: 위치 권한 상태
    func getAuthStatus() -> String {
        let authStatus = CLLocationManager().authorizationStatus    //위치 서비스 권한 상태
        
        switch authStatus {
        case .notDetermined:    //위치 서비스 사용 여부 미선택
            self.status = "notDetermined"
        case .restricted:   //위치 서비스 사용 권한 없음
            self.status = "restricted"
        case .denied:   //위치 서비스 사용 거부 or 설정에서 전역 비활성
            self.status = "denied"
        case .authorized:   //위치 서비스 사용 승인
            self.status = "authorized"
        case .authorizedAlways: //위치 서비스 항상 사용 승인
            self.status = "authorizedAlways"
        case .authorizedWhenInUse:  //앱이 사용중일 때 위치 서비스 사용 승인
            self.status = "authorizedWhenInUse"
        default:    //Unknown
            self.status = "unknown"
        }
        
        return status!
    }
    
    //MARK: - 위치 정보 호출
    func getLocation() {
        let coordinate = locationManager.location?.coordinate
        
        latitude = coordinate?.latitude //위도
        longitude = coordinate?.longitude   //경도
    }
    
    //MARK: - 위치 서비스 권한 확인
    func checkLocationAuth() {
        let locationStatus = getAuthStatus()    //위치 서비스 권한 상태
        
        //위치 서비스 권한이 없는 경우 권한 요청 알림창 활성
        if locationStatus == "notDetermined" || locationStatus == "restricted" || locationStatus == "denied" {
            self.viewUtil.showAlert = true    //알림창 활성
            self.viewUtil.alert = requestAuthAlert() //위치 서비스 권한 요청 알림창
        }
    }
    
    //MARK: - 위치 서비스 권한 요청 알림창
    /// 위치 서비스에 대한 권한을 요청하기 위한 알림창
    /// 설정 버튼 클릭 시, 앱의 설정 화면으로 이동
    /// - Returns: Alert
    func requestAuthAlert() -> Alert {
        return Alert(
            title: Text("위치 서비스 권한"),
            message: Text("악취 접수 등록을 위해 위치 서비스 사용에 대한 권한이 필요합니다."),
            primaryButton: .destructive(
                Text("설정"),
                action: {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)    //앱의 설정 화면으로 이동
                }
            ),
            secondaryButton: .cancel(
                Text("닫기"),
                action: {
                    self.viewUtil.showAlert = false
                }
            )
        )
    }
}
