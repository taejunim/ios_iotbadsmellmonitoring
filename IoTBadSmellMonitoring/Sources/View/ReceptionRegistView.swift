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
    
    var body: some View {
        ZStack {
            //로딩 표시 여부에 따라 표출
            if viewUtil.isLoading {
                viewUtil.loadingView()  //로딩 화면
            }
            
            VStack {
                ScrollView {
                    SelectSmellView(selectSmell: $selectSmell)
                    
                    DividerLine()   //구분선
                    
                    AttachPictureView()
                    
                    DividerLine()   //구분선
                    
                    AddMessageView()
                    
                    DividerLine()
                }
                
                ReceptionRegistButton()
            }
            .navigationBarTitle(Text("악취 접수 등록"), displayMode: .inline) //Navigation Bar 타이틀
            .navigationBarBackButtonHidden(true)    //기본 Back 버튼 숨김
            .navigationBarItems(leading: BackButton())  //커스텀 Back 버튼 추가
            .onAppear {
                receptionViewModel.getSmellTypeCode()   //악취 취기 코드
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
        .gesture(DragGesture(minimumDistance: 0.00001).onChanged {_ in
            viewUtil.dismissKeyboard() //키보드 닫기
        })
    }
}

struct SelectSmellView: View {
    @Binding var selectSmell: [String: String]  //선택한 악취 강도
    
    var body: some View {
        VStack {
            Text("취기 및 악취 강도 선택")
                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
            
            VStack {
                SmellTypeButton()
                
                let smellCode: String = selectSmell["code"] ?? ""  //코드
                let smellName: String = selectSmell["codeName"] ?? ""  //코드 명
                let smellComment: String = selectSmell["codeComment"] ?? ""    //코드 설명

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

//MARK: - 취기 선택 버튼
struct SmellTypeButton: View {
    @State private var showModal = false
    
    var body: some View {
        Button(
            action: {
                self.showModal.toggle()
            },
            label: {
                Text("취기 선택")
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .frame(width: 100, height: 100)
                    .background(Color("Color_3498DB"))
                    .cornerRadius(10)
            }
        )
        .padding()
        .popup(
            isPresented: $showModal,
            type: .default,
            position: .bottom,
            animation: .spring(),
            closeOnTap: false,
            closeOnTapOutside: false,
            view: {
                SmellTypeModalView()
            }
        )
    }
}

struct SmellTypeModalView: View {
    var body: some View {
        VStack {
            Text("취기 선택")
                .fontWeight(.bold)
            
            HStack {
                HStack {
                    Button(
                        action: {
                            
                        },
                        label: {
                            Text("취기 선택")
                                .fontWeight(.bold)
                                .foregroundColor(Color.white)
                                .frame(width: 100, height: 100)
                                .background(Color("Color_3498DB"))
                                .cornerRadius(10)
                        }
                    )
                    .padding()
                }
            }
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
//                        pickedImage?
//                            .resizable()
//                            .frame(width: 150, height: 100)
                        pickedImageArray[index]?
                            .resizable()
                            .frame(width: 195, height: 130)
                            //.frame(width: 225, height: 150)
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
                                        .foregroundColor(.gray)
                                        .font(Font.system(size: 50))
                                }
                                .frame(width: 195, height: 130).clipped()
                                .border(Color.gray)
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
            .background(Color("Color_EFEFEF"))
            
//            HStack {
//                Button(
//                    action: {
//                        self.showingImagePicker.toggle()
//                    },
//                    label: {
//                        if pickedImage == nil {
//                            Text("No")
//                        }
//                        else {
//                            Text("Yes")
//                        }
//                    }
//                )
//                .sheet(isPresented: $showingImagePicker) {
//                    ImagePicker(sourceType: .photoLibrary) { (image) in
//                        self.pickedImage = Image(uiImage: image)
//                        print(image)
//                        print(image.jpegData(compressionQuality: 0.5)!)
//                    }
//                }
//
//                pickedImage?.resizable()
//                    .frame(width: 150, height: 100)
//            }
        }
    }
}

//MARK: - 전달사항 추가 화면
struct AddMessageView: View {
    var body: some View {
        VStack {
            Text("전달사항 추가")
                .fontWeight(.bold)
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
        ReceptionRegistView(selectSmell: [:])
    }
}
