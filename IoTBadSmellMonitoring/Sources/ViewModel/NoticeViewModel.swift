//
//  NoticeViewModel.swift
//  IoTBadSmellMonitoring
//
//  Created by KJ on 2022/03/18.
//

import Foundation

class NoticeViewModel: ObservableObject {
    private let commonAPI = CommonAPIService()  //공통 API Service
    private let codeViewModel = CodeViewModel()
    
    @Published var isClose: Bool = false    //공지사항 팝업 닫기 여부
    @Published var isCloseToday: Bool = false   //공지사항 오늘 하루 보지 않기 여부
    @Published var closedDate: String = ""  //오늘 하루 보지 않기 설정한 일자
    
    @Published var noticeTitle: String = "" //공지사항 제목
    @Published var noticeContent: String = ""   //공지사항 내용
    
    //MARK: - 공지사항 호출
    func getNotice() {
        //공지사항 API 호출
        let request = commonAPI.requestNotice()
        request.execute(
            //API 호출 성공
            onSuccess: { (notice) in
                
                if notice.result == "success" {
                    let data = notice.data!
                    
                    self.noticeTitle = data.noticeTitle //공지사항 제목
                    self.noticeContent = data.noticeContents    //공지사항 내용
                } else {
                    self.isClose = true //팝업 닫기 처리
                }
            },
            //API 호출 실패
            onFailure: { (error) in
                print(error.localizedDescription)
            }
        )
    }
    
    //MARK: - 오늘 하루 닫기 처리
    func closeToday() {
        //현재 일시 API 호출
        codeViewModel.getCurrentDate() { (currentDate) in
            self.isCloseToday = true
            
            let substrDate = currentDate.prefix(10)
            let formatDate = substrDate.components(separatedBy: ["-"]).joined()
            
            UserDefaults.standard.set(self.isCloseToday, forKey: "isCloseNotice")
            UserDefaults.standard.set(formatDate, forKey: "noticeClosedDate")
        }
    }
    
    //MARK: - 공지사항 오늘 하루 닫기 확인
    func checkCloseToday() {
        isCloseToday = UserDefaults.standard.bool(forKey: "isCloseNotice")
        
        if isCloseToday {
            closedDate = UserDefaults.standard.string(forKey: "noticeClosedDate")!  //오늘 하루 보지 않기 설정한 일자
            
            //현재 일시 API 호출
            codeViewModel.getCurrentDate() { (getDate) in
                let substrDate = getDate.prefix(10)
                let currentDate = substrDate.components(separatedBy: ["-"]).joined()
                
                if self.closedDate < currentDate {
                    self.isCloseToday = false
                    
                    UserDefaults.standard.set(self.isCloseToday, forKey: "isCloseNotice")
                }
            }
        } else {
            isClose = false
        }
    }
}
