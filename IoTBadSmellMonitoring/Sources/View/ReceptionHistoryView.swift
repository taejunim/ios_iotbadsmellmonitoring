//
//  ReceptionHistoryView.swift
//  IoTBadSmellMonitoring
//
//  Created by KJ on 2021/06/24.
//

import SwiftUI
import UIKit

//MARK: - 악취 접수 이력 화면
struct ReceptionHistoryView: View {
    @EnvironmentObject var viewUtil: ViewUtil   //화면 Util
    @ObservedObject var viewOptionSet = ViewOptionSet() //화면 Option Set
    @ObservedObject var codeViewModel = CodeViewModel() //Code View Model
    @ObservedObject var historyViewModel = ReceptionHistoryViewModel()   //Reception History View Model
    
    @StateObject private var stateViewUtil = ViewUtil()
    @StateObject private var stateWeatherViewModel = WeatherViewModel()
    @StateObject private var stateSmellViewModel = SmellReceptionViewModel()
    @StateObject private var stateSideMenuViewModel = SideMenuViewModel()
    
    var body: some View {
        //뒤로가기 버튼 클릭 시, 악취 접수 화면으로 이동
        if viewUtil.isBack {
            //악취 접수 등록 화면
            SmellReceptionView()
                .environmentObject(stateViewUtil)
                .environmentObject(stateWeatherViewModel)
                .environmentObject(stateSmellViewModel)
                .environmentObject(stateSideMenuViewModel)
        }
        else {
            ZStack {
                //첨부사진 이미지 팝업 창 활성 여부에 따라 팝업 활성
                if historyViewModel.showImageModal {
                    ImageModalView(historyViewModel: historyViewModel)  //첨부사진 이미지 팝업 창
                        .zIndex(1)
                }
                
                NavigationView {
                    VStack {
                        SearchFieldView(viewUtil: viewUtil, historyViewModel: historyViewModel)   //조회 조건 화면
                        
                        VerticalDividerLine()
                        
                        Spacer()
                        
                        //조회 시 이력 목록 노출
                        if historyViewModel.isSearch {
                            ZStack {
                                //조회 로딩 화면
                                if historyViewModel.isSearchLoading {
                                    viewUtil.searchLoadingView()
                                        .zIndex(1)
                                }
                                
                                HistoryListView(historyViewModel: historyViewModel)   //접수 이력 목록 화면
                            }
                        }
                    }
                    .padding()
                    .navigationBarTitle(Text("악취 접수 이력"), displayMode: .inline) //Navigation Bar 타이틀
                    .navigationBarBackButtonHidden(true)    //기본 Back 버튼 숨김
                    .navigationBarItems(leading: viewUtil.backMenuButton())  //커스텀 Back 버튼 추가
                }
                .onAppear {
                    historyViewModel.getSmellCode()  //악취 강도 코드 호출
                }
            }
            
        }
    }
}

//MARK: - 조회 조건 영역
struct SearchFieldView: View {
    @ObservedObject var viewUtil: ViewUtil
    @ObservedObject var historyViewModel: ReceptionHistoryViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("조회")
                .font(.title3)
                .fontWeight(.bold)
            
            SeatchDateView(historyViewModel: historyViewModel)  //조회 일자

            SearchSmellLevelView(historyViewModel: historyViewModel) //조회 악취 강도

            SearchButton(historyViewModel: historyViewModel)    //조회 버튼
        }
    }
}

//MARK: - 조회 일자
struct SeatchDateView: View {
    @ObservedObject var historyViewModel: ReceptionHistoryViewModel
    
    var body: some View {
        VStack {
            HStack {
                Text("조회 일자")
                    .fontWeight(.bold)
                
                Spacer()
                
                //조회 시작일자
                DatePicker(
                    "",
                    selection: $historyViewModel.searchStartDate,
                    displayedComponents: [.date]
                )
                .labelsHidden()
                .accentColor(.black)
                
                Spacer()
                
                Text("~")
                
                Spacer()
                
                //조회 종료일자
                DatePicker(
                    "",
                    selection: $historyViewModel.searchEndDate,
                    displayedComponents: [.date]
                )
                .labelsHidden()
                .accentColor(.black)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

//MARK: - 조회 악취 강도
struct SearchSmellLevelView: View {
    @ObservedObject var historyViewModel: ReceptionHistoryViewModel
    
    @State private var isExpanded: Bool = false //선택 박스 활성 여부
    
    var body: some View {
        VStack {
            HStack {
                Text("악취 강도")
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                
                Spacer()
                
                Menu {
                    //전체 선택
                    Button(
                        action: {
                            isExpanded.toggle()
                            historyViewModel.selectSmellCode = ""
                            historyViewModel.selectSmellName = "전체"
                        },
                        label: {
                            Text("전체")
                        }
                    )
                    
                    //악취 강도 선택
                    ForEach(historyViewModel.smellCode, id: \.self) { code in
                        let smellCode: String = code["code"] ?? ""  //코드
                        let smellName: String = code["codeName"] ?? ""  //코드 명
                        
                        Button(
                            action: {
                                isExpanded.toggle()
                                historyViewModel.selectSmellCode = smellCode    //선택한 악취 강도 코드
                                historyViewModel.selectSmellName = smellName    //선택한 악취 강도 명
                            },
                            label: {
                                Text(smellName)
                            }
                        )
                    }
                } label: {
                    HStack {
                        Text(historyViewModel.selectSmellCode == "" ? "전체" : historyViewModel.selectSmellName)
                            
                        Spacer()

                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, minHeight: 30)
                    .multilineTextAlignment(.trailing)
                }
                .onTapGesture {
                    isExpanded.toggle()
                }
            }
        }
    }
}

//MARK: - 조회 버튼
struct SearchButton: View {
    @ObservedObject var historyViewModel: ReceptionHistoryViewModel
    
    var body: some View {
        Button(
            action: {
                historyViewModel.isSearchLoading = true //로딩 실행
                historyViewModel.historyList = []   //조회 이력 초기화
                historyViewModel.pageIndex = 0  //페이지 번호 초기화
                historyViewModel.isSearchEnd = false
                
                //악취 접수 이력 조회 실행
                historyViewModel.getHistory() { (history) in
                    historyViewModel.historyList = history
                    historyViewModel.isSearchLoading = false    //로딩 종료
                }
            },
            label: {
                Text("조회")
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding(/*@START_MENU_TOKEN@*/.horizontal/*@END_MENU_TOKEN@*/)
                    .frame(maxWidth: .infinity, minHeight: 30)
                    .background(Color("Color_3498DB"))
            }
        )
    }
}


//MARK: - 악취 접수 이력 목록 화면
struct HistoryListView: View {
    @ObservedObject var historyViewModel: ReceptionHistoryViewModel
    
    @State private var offset = CGFloat.zero
    
    var body: some View {
        //악취 접수 이력 조회가 성공인 경우
        if historyViewModel.result == "success" {
            VStack(alignment: .leading, spacing: 15) {
                Text("이력")
                    .font(.title3)
                    .fontWeight(.bold)
 
                ScrollView {
                    LazyVStack {
                        let historyList = historyViewModel.historyList  //접수 이력 목록
                        
                        //접수 이력 목록 출력
                        ForEach(historyList, id: \.self) { history in
                            HistorySection(historyViewModel: historyViewModel, history: history)
                                .onAppear {
                                    //조회 종료 여부에 따라 추가 조회
                                    if !historyViewModel.isSearchEnd {
                                        //스크롤 하단 이동 시, 마지막 이력 정보일 때 추가 조회 실행
                                        if historyList.last == history {
                                            historyViewModel.pageIndex += 10    //다음 페이지
                                            historyViewModel.AddHistory(pageIndex: historyViewModel.pageIndex)  //추가 접수 이력 정보 호출
                                        }
                                    }
                                }
                        }
                    }
                }
            }
        }
        //악취 접수 이력 조회가 실패인 경우 메세지 출력
        else {
            VStack(alignment: .center) {
                Text(historyViewModel.message)
                
                Spacer()
            }
        }
    }
}

//MARK: - 악취 접수 이력 목록
struct HistorySection: View {
    @ObservedObject var historyViewModel: ReceptionHistoryViewModel
    
    let history: [String:String]    //접수 이력 정보
    @State private var isSelected: Bool = false //해당 접수 이력 선택 여부
    
    var body: some View {
        Section(
            header:
                //악취 접수 이력 Header
                HistoryHeader(historyViewModel: historyViewModel, history: history, isSelected: isSelected)
                    .onTapGesture {
                        self.isSelected.toggle()
                    }
            ,
            content: {
                //접수 이력 선택 시, 해당 이력의 세부 정보 표출
                if isSelected {
                    HistoryRow(historyViewModel: historyViewModel, history: history)
                }
            }
        )
        .accentColor(.black)
    }
}

//MARK: - 악취 접수 이력 Header
struct HistoryHeader: View {
    @ObservedObject var historyViewModel: ReceptionHistoryViewModel
    
    let history: [String:String]    //접수 이력 정보
    let isSelected: Bool    //접수 이력 선택 여부
    
    var body: some View {
        VStack {
            HStack {
                //접수 등록일자
                Text("\(history["registDate"]!)")
                    .font(/*@START_MENU_TOKEN@*/.footnote/*@END_MENU_TOKEN@*/)
                
                Spacer()
            }
            
            Spacer()
            
            HStack {
                //악취 강도 코드 명 - 악취 강도 설명
                Text("\(history["smellName"]!) - \(history["smellComment"]!)")
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: 35, alignment: .leading)
                    .background(Color((history["smellColor"]!)))
                    .cornerRadius(10.0)
                
                Spacer()
                    .frame(width: 20)
                
                Image(systemName: isSelected ? "chevron.up" : "chevron.down")   //선택 여부에 따른 아이콘 변경
            }
            
            VerticalDividerLine()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))   //Section 영역의 빈 공간 없이 설정
    }
}

//MARK: - 악취 접수 이력 세부 정보
struct HistoryRow: View {
    @ObservedObject var historyViewModel: ReceptionHistoryViewModel
    
    let history: [String:String]    //접수 이력 정보
    @State private var detailHistory: [[String:String]] = []    //접수 이력 상세 정보
    @State var pickedImageArray: [Int: Image] = [:] //선택한 이미지 Array
    @State var pickedImageCount: Int = 0  //선택한 이미지 개수
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .center) {
                    Spacer()
                    
                    //취기 이미지
                    Image(history["smellTypeIcon"]!)
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(Color.white)
                        .aspectRatio(1, contentMode: .fit)
                    
                    Spacer()
                    
                    //취기 명
                    Text(history["smellTypeName"]!)
                        .font(.callout)
                        .fontWeight(.bold)
                        .foregroundColor(Color.white)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 5)
                }
                .frame(width: 100, height: 100)
                .background(Color("Color_E4513D"))
                .cornerRadius(10)
                
                Spacer()
                
                Text(history["comment"]!)   //추가 전달사항
                
                Spacer()
            }
            
            Spacer().frame(height: 15)
            
            VStack {
                HStack {
                    //이미지 개수 출력
                    Label("\(detailHistory.count)/5", systemImage: "camera.fill")
                        .font(.subheadline)

                    Spacer()
                }
                
                //수평 스크롤 뷰
                ScrollView(.horizontal) {
                    //등록된 첨부사진이 있는 경우
                    if detailHistory.count > 0 {
                        ScrollViewReader { proxy in
                            HStack {
                                //이미지 개수만큼 이미지 불러오기
                                ForEach(0..<detailHistory.count, id: \.self) { index in
                                    let imagePath = detailHistory[index]["imagePath"]!  //Image Path
                                    let imageUrl = URL(string: imagePath) //Image URL
                                    let imageData = try? Data(contentsOf: imageUrl!)   //Image Data
                                    let uiImage = UIImage(data: imageData!) //UIImage으로 변환
                                    
                                    ZStack {
                                        //첨부사진 이미지
                                        Image(uiImage: uiImage!)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 140, height: 105)
                                    }
                                    .onTapGesture {
                                        historyViewModel.showImagePath = imagePath  //Image Path
                                        historyViewModel.showImageModal.toggle()    //이미지 팝업 창 열기
                                    }
                                }
                            }
                        }
                    }
                    //등록된 첨부사진이 없는 경우
                    else {
                        HStack {
                            Image(systemName: "rectangle.on.rectangle.slash")
                                .renderingMode(.template)
                                .foregroundColor(Color("Color_BEBEBE"))
                                .font(Font.system(size: 50))
                        }
                        .frame(width: 140, height: 105).clipped()
                        .border(Color("Color_BEBEBE"))
                    }
                }
                .padding()
                .background(Color("Color_DFDFDF"))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))  //Section 영역의 빈 공간 없이 설정
        .padding(.bottom, 20)
        .onAppear {
            //해당 접수 이력의 상세 정보 API 호출
            historyViewModel.getDetailHistory(registNo: history["registNo"]!) { (detail) in
                detailHistory = detail
            }
        }
    }
}

//MARK: - 첨부사진 이미지 팝업 창
struct ImageModalView: View {
    @ObservedObject var historyViewModel: ReceptionHistoryViewModel
    
    var body: some View {
        GeometryReader { geometryReader in
            VStack {
                ZStack {
                    let imagePath = historyViewModel.showImagePath  //Image Path
                    let imageUrl = URL(string: imagePath) //Image URL
                    let imageData = try? Data(contentsOf: imageUrl!)   //Image Data
                    let uiImage = UIImage(data: imageData!) //UIImage으로 변환
                    
                    //첨부사진 이미지
                    Image(uiImage: uiImage!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    
                    //이미지 팝업 창 닫기 버튼
                    VStack {
                        HStack {
                            Button(
                                action: {
                                    historyViewModel.showImageModal.toggle()    //팝업 창 닫기
                                },
                                label: {
                                    Image("Close.Icon")
                                        .renderingMode(.template)
                                        .foregroundColor(.white)
                                        .shadow(radius: 5)
                                        .font(Font.system(size: 30))
                                }
                            )
                            
                            Spacer()
                        }
                        
                        Spacer()
                    }
                }
                .padding(.top)
                .cornerRadius(5.0)
                .frame(height: geometryReader.size.height/1.1)
            }
            .padding()
            .frame(width: geometryReader.size.width, height: geometryReader.size.height)
            .background(Color.black.opacity(0.5))
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct ReceptionHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        ReceptionHistoryView()
            .environmentObject(ViewUtil())
    }
}
