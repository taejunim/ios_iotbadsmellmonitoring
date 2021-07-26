//
//  ReceptionHistoryViewModel.swift
//  IoTBadSmellMonitoring
//
//  Created by KJ on 2021/07/12.
//

import Foundation

class ReceptionHistoryViewModel: ObservableObject {
    private let codeViewModel = CodeViewModel() //Code View Model
    private let smellAPI = SmellAPISerivce()    //Smell API Service
    
    @Published var smellCode: [[String:String]] = []  //악취 강도 코드
    @Published var historyList: [[String:String]] = []  //접수 이력 정보 목록
    @Published var detailHistoryList: [[String:String]] = []    //접수 이력 상세 정보 목록
    
    @Published var isSearch: Bool = false   //조회 여부
    @Published var isSearchEnd: Bool = false    //조회 종료 여부
    @Published var isSearchLoading: Bool = false    //조회 로딩 화면 노출 여부
    
    @Published var pageIndex: Int = 0  //페이지 번호(0: 시작, 10 단위)
    @Published var rowsCount: Int = 10 //페이지 당 결과 수
    @Published var searchStartDate: Date = Calendar.current.date(byAdding: .day, value: -7, to: Date())!   //조회 시작일자
    @Published var searchEndDate: Date = Date() //조회 종료일자
    
    @Published var selectSmellCode: String = "" //선택한 악취 강도 코드
    @Published var selectSmellName: String = "" //선택한 악취 강도 명
    
    @Published var showImageModal: Bool = false
    @Published var showImagePath: String = ""
    
    @Published var result: String = ""   //결과 상태
    @Published var message: String = "" //결과 메시지
    
    //MARK: - 악퀴 강도 코드
    func getSmellCode() {
        codeViewModel.getCode(codeGroup: "SMT") { (code) in
            self.smellCode = code
            self.selectSmellName = code[0]["codeName"]! //첫번째 악취 강도 코드
        }
    }
    
    //MARK: - 접수 이력 정보 조회
    func getHistory(completion: @escaping ([[String:String]]) -> Void) {
        
        let searchStartDate: String = "yyyy-MM-dd".dateFormatter(formatDate: self.searchStartDate)  //조회 시작일자
        let searchEndDate: String = "yyyy-MM-dd".dateFormatter(formatDate: self.searchEndDate)  //조회 종료일자
        
        //API 호출 - Request Parameters
        let parameters = [
            "regId": UserDefaults.standard.string(forKey: "userId")!,   //등록자 ID
            "startDate": searchStartDate,   //조회 시작일자
            "endDate": searchEndDate,   //조회 종료일자
            "smellValue": selectSmellCode,  //조회 악취 강도 코드
            "recordCountPerPage": String(rowsCount), //페이지 당 조회 결과 수
            "firstIndex": "0"   //조회 페이지 번호
        ]
        
        //악취 접수 이력 API 호출
        let request = smellAPI.requestHistory(parameters: parameters)
        
        request.execute(
            //API 호출 성공
            onSuccess: { (history) in
                self.isSearch = true
                self.result = history.result   //API 호출 결과 메시지
                
                //API 호출 결과가 성공인 경우
                if self.result == "success" {
                    
                    var historyDictionary: [String:String] = [:]  //Dictionary
                    var historyArray: [[String:String]] = []  //Array
                    
                    //접수 이력 데이터 추출 후 Array에 할당
                    for index in 0..<history.data!.count {
                        let historyData = history.data![index]  //악취 접수 이력 API 정보
                        
                        let smellColor = self.getSmellColor(smellCode: historyData.smellLevelCode)  //악취 강도 색상
                        let smellComment = self.getSmellComment(smellCode: historyData.smellLevelCode)  //악취 강도 설명
                        let smellTypeIcon = self.getSmellTypeIcon(smellTypeCode: historyData.smellTypeCode) //취기 아이콘
                        
                        //접수 이력 정보
                        historyDictionary = [
                            "registNo": historyData.registNo,   //접수 등록번호
                            "smellCode": historyData.smellLevelCode,    //악취 강도 코드
                            "smellName": historyData.smellLevelName,    //악취 강도 명
                            "smellColor": smellColor,   //악취 강도 색상
                            "smellComment": smellComment,   //악취 강도 설명
                            "smellTypeCode": historyData.smellTypeCode, //취기 코드
                            "smellTypeName": historyData.smellTypeName, //취기 명
                            "smellTypeIcon": smellTypeIcon, //취기 아이콘
                            "comment": historyData.comment, //추가 전달사항
                            "registDate": historyData.registDate    //접수 등록일자
                        ]
                        
                        historyArray.append(historyDictionary)
                    }
                    
                    //조회 결과가 10개 미만인 경우 스크롤 조회 방지
                    if history.data!.count < 10 {
                        self.isSearchEnd = true
                    }
                    
                    completion(historyArray)
                }
                //API 호출 결과가 실패인 경우
                else {
                    completion([])
                    self.message = "조회 조건에 맞는 접수 이력이 없습니다."
                }
            },
            //API 호출 실패
            onFailure: { (error) in
                self.isSearch = true
                self.result = "server error"
                self.message = "서버와의 통신이 원활하지 않습니다."
                
                completion([])
                print(error.localizedDescription)
            }
        )
    }
    
    //MARK: - 접수 이력 상세 정보 조회
    func getDetailHistory(registNo: String, completion: @escaping ([[String:String]]) -> Void) {
        
        //API 호출 - Request Parameters
        let parameters = [
            "smellRegisterNo": registNo //악취 접수 번호
        ]
        
        //접수 이력 상세 정보 API 호출
        let request = smellAPI.requestDetailHistory(parameters: parameters)
        
        request.execute(
            //API 호출 성공
            onSuccess: { (detail) in
                if self.result == "success" {
                    var detailDictionary: [String:String] = [:]  //Dictionary
                    var detailArray: [[String:String]] = []  //Array
                    
                    if detail.data != nil {
                        for index in 0..<detail.data!.count {
                            let detailData = detail.data![index]
                            
                            detailDictionary = [
                                "registNo": detailData.registNo,    //접수 등록번호
                                "imageNo": detailData.imageNo,  //이미지 번호
                                "imagePath": detailData.imagePath   //이미지 URL 경로
                            ]

                            detailArray.append(detailDictionary)
                        }
                        
                        completion(detailArray)
                    }
                    else {
                        completion([])
                    }
                }
            },
            //API 호출 실패
            onFailure: { (error) in
                self.result = "server error"
                self.message = "서버와의 통신이 원활하지 않습니다."
                
                completion([])
                print(error.localizedDescription)
            }
        )
    }
    
    //MARK: - 추가 접수 이력 정보 조회
    func AddHistory(pageIndex: Int) {
        let searchStartDate: String = "yyyy-MM-dd".dateFormatter(formatDate: self.searchStartDate)  //조회 시작일자
        let SearchEndDate: String = "yyyy-MM-dd".dateFormatter(formatDate: self.searchEndDate)  //조회 종료일자
        
        //API 호출 - Request Parameters
        let parameters = [
            "regId": UserDefaults.standard.string(forKey: "userId")!,   //등록자 ID
            "startDate": searchStartDate,   //조회 시작일자
            "endDate": SearchEndDate,   //조회 종료일자
            "smellValue": selectSmellCode,  //조회 악취 강도 코드
            "recordCountPerPage": String(rowsCount), //페이지 당 조회 결과 수
            "firstIndex": String(pageIndex)   //조회 페이지 번호
        ]
        
        //악취 접수 이력 API 호출
        let request = smellAPI.requestHistory(parameters: parameters)
        
        request.execute(
            //API 호출 성공
            onSuccess: { (history) in
                self.isSearch = true
                self.result = history.result   //API 호출 결과 메시지
                
                var historyDictionary: [String:String] = [:]  //Dictionary
                var historyArray: [[String:String]] = []  //Array
                
                //API 호출 결과가 성공인 경우
                if self.result == "success" {
                    print("success")
                    
                    //접수 이력 데이터 추출 후 Array에 할당
                    for index in 0..<history.data!.count {
                        let historyData = history.data![index]  //악취 접수 이력 API 정보
                        
                        let smellColor = self.getSmellColor(smellCode: historyData.smellLevelCode)  //악취 강도 색상
                        let smellComment = self.getSmellComment(smellCode: historyData.smellLevelCode)  //악취 강도 설명
                        let smellTypeIcon = self.getSmellTypeIcon(smellTypeCode: historyData.smellTypeCode) //취기 아이콘
                        
                        //접수 이력 정보
                        historyDictionary = [
                            "registNo": historyData.registNo,   //접수 등록번호
                            "smellCode": historyData.smellLevelCode,    //악취 강도 코드
                            "smellName": historyData.smellLevelName,    //악취 강도 명
                            "smellColor": smellColor,   //악취 강도 색상
                            "smellComment": smellComment,   //악취 강도 설명
                            "smellTypeCode": historyData.smellTypeCode, //취기 코드
                            "smellTypeName": historyData.smellTypeName, //취기 명
                            "smellTypeIcon": smellTypeIcon, //취기 아이콘
                            "comment": historyData.comment, //추가 전달사항
                            "registDate": historyData.registDate    //접수 등록일자
                        ]
                        
                        historyArray.append(historyDictionary)
                    }
                    
                    self.historyList.append(contentsOf: historyArray)
                    
                    //현재 페이지의 개수가 10개 미만인 경우, 조회 종료
                    if history.data!.count < 10 {
                        self.isSearchEnd = true //조회 종료
                    }
                    //현재 페이지의 개수가 10개인 경우, 다음 페이지 확인
                    else {
                        self.checkNextPage(currentPageIndex: pageIndex) //다음 페이지 확인
                    }
                }
            },
            //API 호출 실패
            onFailure: { (error) in
                self.isSearch = true
                self.result = "server error"
                self.message = "서버와의 통신이 원활하지 않습니다."
                
                print(error.localizedDescription)
            }
        )
    }
    
    //MARK: - 다음 접수 이력 페이지 확인
    func checkNextPage(currentPageIndex: Int) {
        let searchStartDate: String = "yyyy-MM-dd".dateFormatter(formatDate: self.searchStartDate)  //조회 시작일자
        let searchEndDate: String = "yyyy-MM-dd".dateFormatter(formatDate: self.searchEndDate)  //조회 종료일자
        
        let parameters = [
            "regId": UserDefaults.standard.string(forKey: "userId")!,   //등록자 ID
            "startDate": searchStartDate,   //조회 시작일자
            "endDate": searchEndDate,   //조회 종료일자
            "smellValue": selectSmellCode,  //조회 악취 강도 코드
            "recordCountPerPage": String(rowsCount), //페이지 당 조회 결과 수
            "firstIndex": String(currentPageIndex + 10)   //현재 조회 페이지 번호 + 다음 페이지 번호(10)
        ]
        
        //다음 페이지의 접수 이력 API 호출
        let nextHistory = self.smellAPI.requestHistory(parameters: parameters)
        
        nextHistory.execute(
            //API 호출 성공
            onSuccess: { (nextPage) in
                //다음 페이지의 접수 이력 정보가 없는 경우
                if nextPage.data == nil {
                    self.isSearchEnd = true
                }
            }
        )
    }
    
    //MARK: - 악취 강도 코드에 따른 악취 아이콘
    func getSmellColor(smellCode: String) -> String {
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
    }

    //MARK: - 악취 강도 코드에 따른 악취 강도 설명
    func getSmellComment(smellCode: String) -> String {
        var smellComment: String = ""   //악취 강도 설명
        
        //악취 강도 코드 API 호출 데이터에서 악취 설명 정보 추출
        for code in self.smellCode {
            if code["code"] == smellCode {
                smellComment = code["codeComment"]!
            }
        }
        
        return smellComment
    }
    
    //MARK: - 취기 코드에 따른 취기 아이콘
    func getSmellTypeIcon(smellTypeCode: String) -> String {
        switch smellTypeCode {
        case "001":
            return "Chicken.Smell"
        case "002":
            return "Etc.Smell"
        case "003":
            return "Pig.Smell"
        case "004":
            return "Fertilizer.Smell"
        case "005":
            return "Cow.Smell"
        case "006":
            return "Waste.Smell"
        case "007":
            return "Boiled.Smell"
        case "008":
            return "No.Smell"
        case "009":
            return "Compost.Smell"
        default:
            return "Etc.Smell"
        }
    }
}
