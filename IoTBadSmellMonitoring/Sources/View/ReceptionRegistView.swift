//
//  ReceptionRegistView.swift
//  IoTBadSmellMonitoring
//
//  Created by KJ on 2021/06/24.
//

import SwiftUI

struct ReceptionRegistView: View {
    @Environment(\.presentationMode) var presentationMode   //Back 버튼 기능 추가에 필요
    @ObservedObject var viewUtil = ViewUtil()
    @ObservedObject var receptionViewModel = ReceptionRegistViewModel() //Reception Regist View Model
    
    @State var selectSmell: [String: String]    //선택한 악취 강도
    @State var currentWeather: [String: String]
    
    var body: some View {
        ZStack {
            //로딩 표시 여부에 따라 표출
            if viewUtil.isLoading {
                viewUtil.loadingView()  //로딩 화면
            }
            
            VStack {
                ScrollView {
                    SelectSmellView(viewUtil: viewUtil, receptionViewModel: receptionViewModel, selectSmell: $selectSmell)  //취기 및 악취 강도 선택 화면
                    
                    DividerLine()   //구분선

                    AttachPictureView() //촬영사진 첨부 화면
                    
                    DividerLine()   //구분선
                    
                    AddMessageView(receptionViewModel: receptionViewModel)    //전달사항 추가 화면
                    
                    DividerLine()   //구분선
                }
                
                //취기 선택 팝업 활성화 시 숨김 처리
                if !viewUtil.showModal {
                    ReceptionRegistButton() //접수 등록 버튼
                }
            }
            .navigationBarTitle(Text("악취 접수 등록"), displayMode: .inline) //Navigation Bar 타이틀
            .navigationBarBackButtonHidden(true)    //기본 Back 버튼 숨김
            .navigationBarItems(leading: BackButton())  //커스텀 Back 버튼 추가
            .onAppear {
                receptionViewModel.currentWeather = currentWeather
                receptionViewModel.selectSmellCode = selectSmell["code"] ?? ""
                receptionViewModel.getSmellTypeCode()   //악취 취기 코드
                
                receptionViewModel.selectSmellType = "001"  //선택한 취기 초기화
                receptionViewModel.selectTempSmellType = "001"  //선택한 임시 취기 초기화
                
                print(receptionViewModel.currentWeather)
            }
        }
        .popup(
            isPresented: $viewUtil.showToast,   //팝업 노출 여부
            type: .floater(verticalPadding: 40),
            position: .bottom,
            animation: .easeInOut(duration: 0.0),   //애니메이션 효과
            autohideIn: 2,  //팝업 노출 시간
            closeOnTap: false,
            closeOnTapOutside: false,
            view: {
                viewUtil.toast()    //팝업 화면
            }
        )
        .popup(
            isPresented: $viewUtil.showModal,
            type: .default,
            position: .bottom,
            animation: .spring(),
            closeOnTap: false,
            closeOnTapOutside: false,
            view: {
                //취기 선택 팝업 화면
                SmellTypeModalView(viewUtil: viewUtil, receptionViewModel: receptionViewModel)
                    .edgesIgnoringSafeArea(.all)
            }
        )
        .gesture(DragGesture(minimumDistance: 0.00001).onChanged {_ in
            viewUtil.dismissKeyboard() //키보드 닫기
        })
        .edgesIgnoringSafeArea(!viewUtil.showModal ? .horizontal : .all)
    }
}

//MARK: - 취기 및 악취 강도 선택 화면
struct SelectSmellView: View {
    @ObservedObject var viewUtil: ViewUtil
    @ObservedObject var receptionViewModel: ReceptionRegistViewModel
    
    @Binding var selectSmell: [String: String]  //선택한 악취 강도

    var body: some View {
        VStack {
            Text("취기 및 악취 강도 선택")
                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
            
            VStack {
                SmellTypeButton(viewUtil: viewUtil, receptionViewModel: receptionViewModel) //취기 선택 버튼
                
                let smellCode: String = selectSmell["code"] ?? ""   //코드
                let smellName: String = selectSmell["codeName"] ?? ""   //코드 명
                let smellComment: String = selectSmell["codeComment"] ?? "" //코드 설명
                
                //악취 강도 선택 버튼 색상
                let smellColor: String = {
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
                }()
                
                Text("\(smellName) - \(smellComment)")
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: 35, alignment: .leading)
                    .background(Color(smellColor))
                    .cornerRadius(10.0)
            }
        }
        .padding()
    }
}

//MARK: - 취기 선택 팝업 호출 버튼
struct SmellTypeButton: View {
    @ObservedObject var viewUtil: ViewUtil
    @ObservedObject var receptionViewModel: ReceptionRegistViewModel
    
    var body: some View {
        Button(
            action: {
                viewUtil.showModal.toggle()
            },
            label: {
                VStack(alignment: .center) {
                    
                    ForEach(receptionViewModel.smellTyepCode, id: \.self) { code in
                        let smellTypeCode: String = code["code"] ?? ""  //코드
                        let smellTypeName: String = code["codeName"] ?? ""  //코드
                        
                        //취기 선택 버튼 아이콘 이미지명
                        let smellTypeIcon: String = {
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
                        }()
                        
                        if smellTypeCode == receptionViewModel.selectSmellType {
                            Spacer()
                            
                            //취기 이미지
                            Image(smellTypeIcon)
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(Color.white)
                                .aspectRatio(1, contentMode: .fit)
                            
                            Spacer()
                            
                            //취기 명
                            Text(smellTypeName)
                                .font(.callout)
                                .fontWeight(.bold)
                                .foregroundColor(Color.white)
                                .multilineTextAlignment(.center)
                                .padding(.vertical, 5)
                        }
                    }
                }
                .frame(width: 100, height: 100)
                .background(Color("Color_E4513D"))
                .cornerRadius(10)
            }
        )
        .padding()
    }
}

//MARK: - 취기 선택 팝업
struct SmellTypeModalView: View {
    @ObservedObject var viewUtil: ViewUtil
    @ObservedObject var receptionViewModel: ReceptionRegistViewModel
    
    var body: some View {
        GeometryReader { geometryReader in
            VStack {
                VStack {
                    Text("취기 선택")
                        .fontWeight(.bold)
                    
                    SmellTypeListView(receptionViewModel: receptionViewModel)   //취기 목록 화면
                    SmellTypeModalButton(viewUtil: viewUtil, receptionViewModel: receptionViewModel) //취기 선택 팝업 하단 버튼
                }
                .padding(.top)
                .background(Color.white)
                .cornerRadius(5.0)
                .frame(height: geometryReader.size.height/1.5)
            }
            .padding()
            .frame(width: geometryReader.size.width, height: geometryReader.size.height)
            .background(Color.black.opacity(0.5))
        }
    }
}

//MARK: - 취기 선택 팝업: 취기 목록 화면
struct SmellTypeListView: View {
    @ObservedObject var receptionViewModel: ReceptionRegistViewModel
    
    var body: some View {
        ScrollView{
            let totalCount: Int = self.receptionViewModel.smellTyepCode.count   //취기 총 개수
            
            //한 줄에 3개씩 출력 (3 x n)
            ForEach(0..<totalCount/3, id: \.self) { row in
                HStack {
                    ForEach(0..<3) { index in
                        let codeIndex = row * 3 + index //코드 Index
                        let smellTypeCode: String = receptionViewModel.smellTyepCode[codeIndex]["code"] ?? ""   //취기 코드
                        let smellTypeName: String = receptionViewModel.smellTyepCode[codeIndex]["codeName"] ?? ""   //취기 명
                        
                        //취기 선택 버튼 아이콘 이미지명
                        let smellTypeIcon: String = {
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
                        }()
                        
                        Button(
                            action: {
                                self.receptionViewModel.selectTempSmellType = smellTypeCode //선택한 취기 코드
                            },
                            label: {
                                VStack {
                                    VStack(alignment: .center) {
                                        Spacer()
                                        
                                        //취기 이미지
                                        Image(smellTypeIcon)
                                            .resizable()
                                            .renderingMode(.template)
                                            .foregroundColor(smellTypeCode == receptionViewModel.selectTempSmellType ? Color.white : Color.black)
                                            .aspectRatio(1, contentMode: .fit)
                                        
                                        Spacer()
                                        
                                        //취기 명
                                        Text(smellTypeName)
                                            .font(.callout)
                                            .fontWeight(.bold)
                                            .foregroundColor(smellTypeCode == receptionViewModel.selectTempSmellType ? Color.white : Color.black)
                                            .multilineTextAlignment(.center)
                                            .padding(.vertical, 5)
                                    }
                                    .frame(width: 100, height: 100)
                                    .background(smellTypeCode == receptionViewModel.selectTempSmellType ? Color("Color_E4513D") : Color("Color_E0E0E0"))
                                    .cornerRadius(10)
                                    
                                    //라디오 버튼
                                    ZStack {
                                        Circle()
                                            .fill(Color.white)
                                            .frame(width: 18, height: 18)
                                            .overlay(
                                                Circle()
                                                    .stroke(smellTypeCode == receptionViewModel.selectTempSmellType ? Color("Color_E4513D") : Color.gray, lineWidth: 1)
                                            )
                                        
                                        //취기 선택한 경우 해당 라디오 버튼 체크 표시
                                        if smellTypeCode == receptionViewModel.selectTempSmellType {
                                            Circle()
                                                .fill(Color("Color_E4513D"))
                                                .frame(width: 10, height: 10)
                                        }
                                    }
                                }
                            }
                        )
                        
                        //row의 마지막 Spacer 제외
                        if index != 2 {
                            Spacer()
                        }
                    }
                }
                .padding()
            }
        }
    }
}

//MARK: - 취기 선택 팝업: 하단 버튼
struct SmellTypeModalButton: View {
    @ObservedObject var viewUtil: ViewUtil
    @ObservedObject var receptionViewModel: ReceptionRegistViewModel
    
    var body: some View {
        HStack {
            //취소 버튼 - 창닫기
            Button(
                action: {
                    viewUtil.showModal.toggle()
                    receptionViewModel.selectTempSmellType = receptionViewModel.selectSmellType
                },
                label: {
                    Text("취소")
                        .fontWeight(.bold)
                        .foregroundColor(Color.white)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, maxHeight: 35)
                        .background(Color("Color_E4513D"))
                }
            )
            
            Spacer().frame(width: 0)
            
            //선택 완료 버튼
            Button(
                action: {
                    viewUtil.showModal.toggle()
                    receptionViewModel.selectSmellType = receptionViewModel.selectTempSmellType
                },
                label: {
                    Text("완료")
                        .fontWeight(.bold)
                        .foregroundColor(Color.white)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, maxHeight: 35)
                        .background(Color("Color_3498DB"))
                }
            )
        }
    }
}

//MARK: - 촬영사진 첨부 화면
struct AttachPictureView: View {
    @State private var showImagePicker = false
    @State var pickedImage: Image?
    @State var pickedImageArray: [Int: Image] = [:]
    @State var pickedImageCounter: Int = 0
    @State var maxImage: Int = 5
    
    var body: some View {
        VStack {
            Text("촬영사진 첨부")
                .fontWeight(.bold)
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(0..<pickedImageCounter, id: \.self) { index in
                        ZStack {
                            pickedImageArray[index]?
                                .resizable()
                                .frame(width: 195, height: 130)
                                //.frame(width: 225, height: 150)
                        }
                    }
                    
                    if maxImage > pickedImageCounter {
                        Button(
                            action: {
                                self.showImagePicker.toggle()
                            },
                            label: {
                                HStack {
                                    //Image(systemName: "photo.on.rectangle.angled")
                                    //Image(systemName: "plus.viewfinder")
                                    Image(systemName: "plus.rectangle.on.rectangle")
                                        .renderingMode(.template)
                                        .foregroundColor(Color("Color_BEBEBE"))
                                        .font(Font.system(size: 50))
                                }
                                .frame(width: 195, height: 130).clipped()
                                .border(Color("Color_BEBEBE"))
                            }
                        )
                        .sheet(isPresented: $showImagePicker) {
                            ImagePicker(sourceType: .photoLibrary) { (image) in
                                self.pickedImage = Image(uiImage: image)
                                pickedImageArray.updateValue(pickedImage!, forKey: pickedImageCounter)
                                print(image)
                                print(image.jpegData(compressionQuality: 0.5)!)
                                pickedImageCounter += 1
                            }
                        }
                    }
                }
            }
            .padding()
            .background(Color("Color_E0E0E0"))
        }
    }
}

//MARK: - 전달사항 추가 화면
struct AddMessageView: View {
    @ObservedObject var receptionViewModel: ReceptionRegistViewModel
    
    var body: some View {
        VStack {
            Text("추가 전달사항")
                .fontWeight(.bold)
            
            TextEditor(text: $receptionViewModel.addMessage)
                .padding()
                .border(Color("Color_7F7F7F"), width: 1)
                .cornerRadius(8)
                .padding()
        }
    }
}

//MARK: - 악취 접수 등록 버튼
struct ReceptionRegistButton: View {
    var body: some View {
        Button(
            action: {
            },
            label: {
                Text("등록")
                    .font(/*@START_MENU_TOKEN@*/.title2/*@END_MENU_TOKEN@*/)
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, maxHeight: 40)
                    .background(Color("Color_3498DB"))
                    //.background(signUpViewModel.isInputComplete ? Color("Color_3498DB") : Color("Color_BEBEBE"))   //회원가입 정보 입력에 따른 배경색상 변경
            }
        )
    }
}

struct ReceptionRegistView_Previews: PreviewProvider {
    @State private var viewOptionSet = ViewOptionSet() //화면 Option Set
    
    init() {
        viewOptionSet.navigationBarOption() //Navigation Bar 옵션
    }
    
    static var previews: some View {
        ReceptionRegistView(selectSmell: [:], currentWeather: [:])
        //SmellTypeModalView()
    }
}
