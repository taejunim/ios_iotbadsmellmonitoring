//
//  ReceptionRegistView.swift
//  IoTBadSmellMonitoring
//
//  Created by KJ on 2021/06/24.
//

import SwiftUI

//MARK: - 악취 접수 등록 화면
struct ReceptionRegistView: View {
    @Environment(\.presentationMode) var presentationMode   //Back 버튼 기능 추가에 필요
    
    @EnvironmentObject var viewUtil: ViewUtil   //View Util
    @ObservedObject var viewOptionSet = ViewOptionSet() //화면 Option Set
    @ObservedObject var keyboardUtil = KeyboardUtil()
    @ObservedObject var location = Location()   //위치 서비스 호출
    @ObservedObject var receptionViewModel = ReceptionRegistViewModel() //Reception Regist View Model
    @State var selectSmell: [String: String]    //선택한 악취 강도
    
    var body: some View {
        ZStack {
            //취기 선택 팝업 창
            if viewUtil.showModal {
                SmellTypeModalView(viewUtil: viewUtil, receptionViewModel: receptionViewModel)
                    .zIndex(1)
            }
            
            //악취 접수 등록 화면
            VStack {
                ScrollView {
                    VStack {
                        SelectSmellView(viewUtil: viewUtil, receptionViewModel: receptionViewModel, selectSmell: $selectSmell)  //취기 및 악취 강도 선택 화면
                        
                        DividerLine()   //구분선

                        AttachPictureView(viewUtil: viewUtil, receptionViewModel: receptionViewModel) //촬영사진 첨부 화면
                        
                        DividerLine()   //구분선
                        
                        AddMessageView(receptionViewModel: receptionViewModel)    //전달사항 추가 화면
                        
                        DividerLine()   //구분선
                    }
                    .offset(x: 0, y: -keyboardUtil.currentHeight)   //키보드 활성화 시, 키보드 높이 만큼 화면 올리기
                }
                
                ReceptionRegistButton(viewUtil: viewUtil, location: location, receptionViewModel: receptionViewModel)   //접수 등록 버튼
            }
            .navigationBarTitle(Text("악취 접수 등록"), displayMode: .inline) //Navigation Bar 타이틀
            .navigationBarBackButtonHidden(true)    //기본 Back 버튼 숨김
            .navigationBarItems(leading: BackButton())  //커스텀 Back 버튼 추가
        }
        .onAppear {
            receptionViewModel.selectSmellCode = selectSmell["code"] ?? ""  //선택한 악취 코드
            receptionViewModel.getSmellTypeCode()   //악취 취기 코드
            
            receptionViewModel.selectSmellType = "000"  //선택한 취기 초기화
            receptionViewModel.selectTempSmellType = "000"  //선택한 임시 취기 초기화
            receptionViewModel.pickedImageArray = [:]   //선택한 이미지 배열 초기화
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
        .gesture(DragGesture(minimumDistance: 0.00001).onChanged { _ in
            viewUtil.dismissKeyboard() //키보드 닫기
        })
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
                
                //악취 강도 명 - 악취 강도 설명
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
                viewUtil.showModal.toggle() //버튼 클릭 시, 취기 선택 팝업 호출
            },
            label: {
                VStack(alignment: .center) {
                    Spacer()
                    if receptionViewModel.selectSmellType == "000" {
                        Spacer()
                        //취기 이미지
                        Image(systemName: "plus.rectangle")
                            .renderingMode(.template)
                            .foregroundColor(Color("Color_BEBEBE"))
                            .font(Font.system(size: 65))
                        
                        Spacer()
                        
                        //취기 명
                        Text("취기 선택")
                            .font(.callout)
                            .fontWeight(.bold)
                            .foregroundColor(Color("Color_BEBEBE"))
                            .multilineTextAlignment(.center)
                            .padding(.vertical, 5)
                    }
                    else {
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
                            
                            //선택한 취기 버튼
                            if smellTypeCode == receptionViewModel.selectSmellType {
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
                }
                .frame(width: 120, height: 120)
                .background(receptionViewModel.selectSmellType == "000" ? Color("Color_DFDFDF") : Color("Color_E4513D"))
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
        .edgesIgnoringSafeArea(.all)
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
                        
                        //취기 선택 버튼
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
                                            //.foregroundColor(Color.black)
                                            .foregroundColor(smellTypeCode == receptionViewModel.selectTempSmellType ? Color.white : Color.black)
                                            .aspectRatio(1, contentMode: .fit)
                                        
                                        Spacer()
                                        
                                        //취기 명
                                        Text(smellTypeName)
                                            .font(.callout)
                                            .fontWeight(.bold)
                                            //.foregroundColor(Color.black)
                                            .foregroundColor(smellTypeCode == receptionViewModel.selectTempSmellType ? Color.white : Color.black)
                                            .multilineTextAlignment(.center)
                                            .padding(.vertical, 5)
                                    }
                                    .frame(width: 100, height: 100)
                                    .background(smellTypeCode == receptionViewModel.selectTempSmellType ? Color("Color_E4513D") : Color("Color_DFDFDF"))
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
                    viewUtil.showModal.toggle() //팝업 노출 여부 상태변경
                    receptionViewModel.selectTempSmellType = receptionViewModel.selectSmellType //기존 선택된 취기로 변경
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
                    viewUtil.showModal.toggle() //팝업 노출 여부 상태변경
                    receptionViewModel.selectSmellType = receptionViewModel.selectTempSmellType //선택한 취기로 변경
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
    @ObservedObject var viewUtil: ViewUtil
    @ObservedObject var receptionViewModel: ReceptionRegistViewModel
    
    @State private var isReset: Bool = false  //초기화 여부
    @State private var showImagePicker: Bool = false  //이미지 Picker 노출 여부
    @State var imageMaxCount: Int = 5    //이미지 최대 개수
    @State var tapImage: String = ""
    @Namespace var addImageButton   //이미지 추가 버튼
    
    var body: some View {
        VStack {
            Text("촬영사진 첨부")
                .fontWeight(.bold)
            
            //선택한 사진 개수 및 선택한 사진 초기화 버튼
            HStack {
                Label("\(receptionViewModel.pickedImageCount)/\(imageMaxCount)", systemImage: "camera.fill")
                    .font(.subheadline)
    
                Spacer()
                
                //선택한 사진 초기화 버튼
                Button(
                    action: {
                        var registAlert: Alert {
                            return Alert(
                                title: Text("촬영사진 첨부 초기화"),
                                message: Text("첨부한 촬영사진 초기화를 진행 하시겠습니까?"),
                                primaryButton: .destructive(
                                    Text("확인"),
                                    action: {
                                        receptionViewModel.pickedImageArray = [:]   //선택한 이미지 배열에 추가
                                        receptionViewModel.imageArray = []  //접수 등록 API 이미지 데이터
                                        receptionViewModel.pickedImageCount = 0   //선택한 이미지 개수 Count
                                    }
                                ),
                                secondaryButton: .cancel(
                                    Text("닫기"),
                                    action: {
                                        viewUtil.showAlert = false
                                    }
                                )
                            )
                        }
                        
                        viewUtil.showAlert = true   //알림창 호출 여부
                        viewUtil.alert = registAlert    //등록 알림창 호
                    },
                    label: {
                        //새로고침 버튼
                        Image("Refresh.Icon")
                            .renderingMode(.template)
                            .resizable()
                            .foregroundColor(.black)
                            .frame(width: 20, height: 20)
                    }
                )
                .alert(isPresented: $viewUtil.showAlert) {
                    viewUtil.alert! //알림창 호출
                }
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal) {
                ScrollViewReader { proxy in
                    HStack {
                        //선택한 이미지 개수만큼 이미지 출력
                        ForEach(0..<receptionViewModel.pickedImageCount, id: \.self) { index in
                            ZStack {
                                receptionViewModel.pickedImageArray[index]?
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 140, height: 105)
                                    //.frame(width: 195, height: 130)
                                    //.frame(width: 225, height: 150)
                                
                                //추후 사진 개별 삭제 필요 시 추가
                                //if index == Int(tapImage) {
                                //    Color(.gray).opacity(0.5)
                                //        .ignoresSafeArea()
                                //        .zIndex(1)
                                //}
                            }
                            //.onTapGesture {
                            //    tapImage = String(index)
                            //}
                        }
                        .onAppear {
                            proxy.scrollTo(addImageButton)  //스크롤 이동 처리
                        }
                        
                        //이미지 추가 버튼
                        if imageMaxCount > receptionViewModel.pickedImageCount {
                            Button(
                                action: {
                                    self.showImagePicker.toggle()   //이미지 선택 창 호출
                                },
                                label: {
                                    HStack {
                                        Image(systemName: "plus.rectangle.on.rectangle")
                                            .renderingMode(.template)
                                            .foregroundColor(Color("Color_BEBEBE"))
                                            .font(Font.system(size: 50))
                                    }
                                    .frame(width: 140, height: 105)
                                    .border(Color("Color_BEBEBE"))
                                    .id(addImageButton)
                                }
                            )
                            .sheet(isPresented: $showImagePicker) {
                                ImagePicker(sourceType: .photoLibrary) { (image) in
                                    receptionViewModel.pickedImage = Image(uiImage: image)  //선택한 이미지 변환 UIImage -> Image
                                    receptionViewModel.pickedImageArray.updateValue(receptionViewModel.pickedImage!, forKey: receptionViewModel.pickedImageCount)    //선택한 이미지 배열에 추가
                                    receptionViewModel.imageArray.append(image) //접수 등록 API 이미지 데이터 추가
                                    receptionViewModel.pickedImageCount += 1   //선택한 이미지 개수 Count
                                }
                            }
                        }
                    }
                }
            }
            .padding()
            .background(Color("Color_DFDFDF"))
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
            
            //전달사항 입력 창
            TextEditor(text: $receptionViewModel.addMessage)
                .padding()
                .border(Color("Color_7F7F7F"), width: 1)
                .frame(height: 100)
                .padding()
        }
    }
}

//MARK: - 악취 접수 등록 버튼
struct ReceptionRegistButton: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var viewUtil: ViewUtil   //View Util
    @ObservedObject var location: Location  //위치 서비스
    @ObservedObject var receptionViewModel: ReceptionRegistViewModel
    
    @State var disabledButton: Bool = false //버튼 Disabled 여부
    
    var body: some View {
        Button(
            action: {
                viewUtil.dismissKeyboard() //키보드 닫기
                
                let locationStatus = location.getAuthStatus()   //위치 서비스 권한 상태
                
                //위치 서비스 권한 상태에 따른 등록 가능 여부 처리
                if locationStatus == "notDetermined" || locationStatus == "restricted" || locationStatus == "denied" {
                    viewUtil.showAlert = true    //알림창 활성
                    viewUtil.alert = location.requestAuthAlert() //위치 서비스 권한 요청 알림창
                }
                else {
                    //접수 시간대에 따른 등록 가능 여부 확인 후, 등록 실행
                    receptionViewModel.isTimeZoneValid() { (valid) in
                        if valid {
                            if receptionViewModel.isSmellTypeValid() {
                                //등록 알림창
                                var registAlert: Alert {
                                    return Alert(
                                        title: Text("악취 접수 등록"),
                                        message: Text("악취 접수 등록을 진행하시겠습니까?"),
                                        primaryButton: .destructive(
                                            Text("등록"),
                                            action: {
                                                viewUtil.isLoading = true   //로딩 시작
                                                disabledButton = true  //버튼 비활성화
                                                
                                                //악취 접수 등록 실행
                                                receptionViewModel.registReception() { (result) in
                                                    viewUtil.isLoading = false   //로딩 종료
                                                    
                                                    viewUtil.showToast = true   //Toast 팝업
                                                    viewUtil.toastMessage = receptionViewModel.message
                                                    
                                                    if result == "success" {
                                                        //현재시간 기준으로 1.5초 후 실행
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                                            viewUtil.isViewDismiss = true   //창 닫힘 여부
                                                            self.presentationMode.wrappedValue.dismiss()    //Navigation View 닫기
                                                        }
                                                    }
                                                    else {
                                                        self.disabledButton = false //버튼 활성화
                                                    }
                                                }
                                            }
                                        ),
                                        secondaryButton: .cancel(
                                            Text("취소"),
                                            action: {
                                                viewUtil.showAlert = false
                                            }
                                        )
                                    )
                                }
                                
                                viewUtil.showAlert = true   //알림창 호출 여부
                                viewUtil.alert = registAlert    //등록 알림창 호출
                            }
                            else {
                                viewUtil.showToast = true
                                viewUtil.toastMessage = receptionViewModel.validMessage
                            }
                        }
                        //접수 등록 불가인 경우 Toast 메시지 출력
                        else {
                            viewUtil.showToast = true
                            viewUtil.toastMessage = receptionViewModel.validMessage
                        }
                    }
                }
            },
            label: {
                Text("등록")
                    .font(/*@START_MENU_TOKEN@*/.title2/*@END_MENU_TOKEN@*/)
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, maxHeight: 40)
                    .background(disabledButton ? Color("Color_BEBEBE"): Color("Color_3498DB"))   //등록 진행 여부에 따른 버튼 색상 변경
            }
        )
        .alert(isPresented: $viewUtil.showAlert) {
            viewUtil.alert! //알림창 호출
        }
        .disabled(disabledButton)    //등록 진행 시에 버튼 클릭 방지를 위한 비활성화
    }
}

struct ReceptionRegistView_Previews: PreviewProvider {
    static var previews: some View {
        ReceptionRegistView(selectSmell: [:])
            .environmentObject(ViewUtil())
    }
}
