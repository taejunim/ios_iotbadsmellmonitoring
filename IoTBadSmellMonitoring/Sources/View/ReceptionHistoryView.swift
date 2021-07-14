//
//  ReceptionHistoryView.swift
//  IoTBadSmellMonitoring
//
//  Created by KJ on 2021/06/24.
//

import SwiftUI

struct ReceptionHistoryView: View {
    @EnvironmentObject var viewUtil: ViewUtil   //화면 Util
    @ObservedObject var viewOptionSet = ViewOptionSet() //화면 Option Set
    
    @ObservedObject var codeViewModel = CodeViewModel() //Code View Model
    @ObservedObject var hisotyViewModel = ReceptionHistoryViewModel()   //Reception History View Model
    
    var body: some View {
        NavigationView {
            VStack {
                SearchFieldView(hisotyViewModel: hisotyViewModel)
                VerticalDividerLine()
                
                Spacer()
                
                HistoryListView()
            }
            .padding()
            .navigationBarTitle(Text("악취 접수 이력"), displayMode: .inline) //Navigation Bar 타이틀
            .navigationBarBackButtonHidden(true)    //기본 Back 버튼 숨김
            .navigationBarItems(leading: BackButton())  //커스텀 Back 버튼 추가
        }
        .onAppear {
            hisotyViewModel.getSmellCode()
        }
    }
}

struct SearchFieldView: View {
    @ObservedObject var hisotyViewModel: ReceptionHistoryViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("조회")
                .font(.title3)
                .fontWeight(.bold)
            
            SeatchDateView(hisotyViewModel: hisotyViewModel)

            SearchSmellLevelView(hisotyViewModel: hisotyViewModel)

            SearchButton(hisotyViewModel: hisotyViewModel)
        }
    }
}

struct SeatchDateView: View {
    @ObservedObject var hisotyViewModel: ReceptionHistoryViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("조회 일자")
                    .fontWeight(.bold)
                
                Spacer()
                
                DatePicker(
                    "",
                    selection: $hisotyViewModel.searchStartDate,
                    displayedComponents: [.date]
                )
                .labelsHidden()
                .accentColor(.black)
                
                Text("~")
                
                DatePicker(
                    "",
                    selection: $hisotyViewModel.searchEndDate,
                    displayedComponents: [.date]
                )
                .labelsHidden()
                .accentColor(.black)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct SearchSmellLevelView: View {
    @ObservedObject var hisotyViewModel: ReceptionHistoryViewModel
    
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack {
                Text("악취 강도")
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)

//                DisclosureGroup(
//                    isExpanded: $isExpanded,
//                    content: {
//                        VStack(spacing: 10) {
//                            Divider()
//                                .frame(height: 1)
//                                .background(Color("Color_EFEFEF"))
//                                .padding(.vertical, 5)
//
//                            ForEach(hisotyViewModel.smellCode, id: \.self) { code in
//                                let smellCode: String = code["code"] ?? ""  //코드
//                                let smellName: String = code["codeName"] ?? ""  //코드 명
//
//                                Text(smellName)
//                                    .frame(maxWidth: .infinity)
//                                    .border(Color.white)
//                                    .onTapGesture {
//                                        hisotyViewModel.selectSmellCode = smellCode
//                                        hisotyViewModel.selectSmellName = smellName
//
//                                        withAnimation {
//                                            self.isExpanded.toggle()
//                                        }
//                                    }
//                            }
//
//                            Divider()
//                                .frame(height: 1)
//                                .background(Color("Color_EFEFEF"))
//                                .padding(.vertical, 5)
//                        }
//                    },
//                    label: {
//                        Text(hisotyViewModel.selectSmellName)
//                            .frame(maxWidth: .infinity)
//                    }
//                )
//                .accentColor(.black)
//                .border(Color.white)
//                .onTapGesture {
//                    withAnimation {
//                        self.isExpanded.toggle()
//                    }
//                }
//                .padding(.horizontal)
            }
        }
    }
}

struct SearchButton: View {
    @ObservedObject var hisotyViewModel: ReceptionHistoryViewModel
    
    var body: some View {
        Button(
            action: {
                hisotyViewModel.getHistory()
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

struct HistoryListView: View {
    @State private var showContent: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("이력")
                .font(.title3)
                .fontWeight(.bold)
            
            List {
                Section(
                    header: Text("Header"),
                    content: {
                        if showContent {
                            
                        }
                        Text("1")
                        Text("2")
                        Text("3")
                        Text("4")
                    }
                )
                .accentColor(.black)
                .onTapGesture {
                    self.showContent.toggle()
                }
                
            }
            .listStyle(InsetGroupedListStyle())
            .listRowBackground(Color.blue)
        }
    }
}

struct ReceptionHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        ReceptionHistoryView()
    }
}
