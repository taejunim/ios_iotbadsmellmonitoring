//
//  CustomControlView.swift
//  IoTBadSmellMonitoring
//
//  Created by KJ on 2021/06/03.
//

import SwiftUI

//Text Field 밑줄
struct TextFiledUnderLine: View {
    var body: some View {
        Divider()
            .frame(height: 1)
            .background(/*@START_MENU_TOKEN@*//*@PLACEHOLDER=View@*/Color("Color_E0E0E0")/*@END_MENU_TOKEN@*/)
            .padding(.bottom, 10)
    }
}

//필수입력(*) Label
struct RequiredInputLabel: View {
    var body: some View {
        Text("*")
            .foregroundColor(.red)
    }
}

//Image Picker - 이미지 선택창
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
