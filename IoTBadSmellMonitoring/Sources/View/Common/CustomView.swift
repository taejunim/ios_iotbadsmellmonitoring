//
//  CustomView.swift
//  IoTBadSmellMonitoring
//
//  Created by KJ on 2021/06/03.
//

import SwiftUI

//MARK: - 구분선
struct DividerLine: View {
    var body: some View {
        Divider()
            .frame(height: 1)
            .background(Color("Color_EFEFEF"))
            .padding(.all, 10)
    }
}

//MARK: - 구분선 - Vertical
struct VerticalDividerLine: View {
    var body: some View {
        Divider()
            .frame(height: 1)
            .background(Color("Color_EFEFEF"))
            .padding(.vertical, 10)
    }
}

//MARK: - Text Field 밑줄
struct TextFiledUnderLine: View {
    var body: some View {
        Divider()
            .frame(height: 1)
            .background(Color("Color_EFEFEF"))
            .padding(.bottom, 10)
    }
}

//MARK: - 필수입력(*) Label
struct RequiredInputLabel: View {
    var body: some View {
        Text("*")
            .foregroundColor(Color("Color_E4513D"))
    }
}

//MARK: - Back 버튼
struct BackButton: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewUtil: ViewUtil
    
    var body: some View {
        Button(
            action: {
                viewUtil.isViewDismiss = true
                self.presentationMode.wrappedValue.dismiss()
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
}

//MARK: - Image Picker - 이미지 선택창
struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) private var presentationMode
    
    let sourceType: UIImagePickerController.SourceType
    let onPickedImage: (UIImage) -> ()
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let imagePicker: ImagePicker
        
        init(imagePicker: ImagePicker) {
            self.imagePicker = imagePicker
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            guard let image = info[.originalImage] as? UIImage else { return }
            self.imagePicker.onPickedImage(image)
            self.imagePicker.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            self.imagePicker.presentationMode.wrappedValue.dismiss()
        }
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = context.coordinator
        return imagePickerController
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(imagePicker: self)
    }
}
