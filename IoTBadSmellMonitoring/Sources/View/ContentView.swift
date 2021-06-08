//
//  ContentView.swift
//  IoTBadSmellMonitoring
//
//  Created by KJ on 2021/05/27.
//

import SwiftUI

struct ContentView: View {
    @State var position: Int = 0
    
    @State private var showingImagePicker = false
    @State var pickedImage: Image?
    
    var body: some View {
        NavigationView {
            VStack {
                        Button(action: {
                            self.showingImagePicker.toggle()
                        }, label: {
                            Text("Image Picker")
                        }).sheet(isPresented: $showingImagePicker) {
                            ImagePicker(sourceType: .photoLibrary) { (image) in
                                self.pickedImage = Image(uiImage: image)
                                print(image)
                                print(image.jpegData(compressionQuality: 0.5)!)
                            }
                        }
                        pickedImage?.resizable()
                            .frame(height:300)
                    }
//            HStack {
//                Spacer()
//
//                NavigationLink(
//                    destination: LaunchScreen(),
//                    label: {
//                        Text("1번")
//                    })
//
//                Spacer()
//
//                NavigationLink(
//                    destination: MainView(),
//                    label: {
//                        Text("2번")
//                    })
//
//                Spacer()
//            }
        }
//        VStack {
//            Spacer()
//
//            ZStack {
//                Hello()
//                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.green).opacity(0.5))
//                    .alignmentGuide(HorizontalAlignment.center, computeValue: { d in self.helloH(d) })
//                    .alignmentGuide(VerticalAlignment.center, computeValue: { d in self.helloV(d) })
//
//                World()
//                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.yellow).opacity(0.5))
//                    .alignmentGuide(HorizontalAlignment.center, computeValue: { d in self.worldH(d) })
//                    .alignmentGuide(VerticalAlignment.center, computeValue: { d in self.worldV(d) })
//
//            }
//
//            Spacer()
//
//            HStack {
//                Button(action: { withAnimation(.easeInOut(duration: 1.0)) { self.position = 0 } }, label: {
//                    Rectangle().frame(width: 50, height: 50).overlay(Text("H W").foregroundColor(.black))
//                })
//
//                Button(action: { withAnimation(.easeInOut(duration: 1.0)) { self.position = 1 } }, label: {
//                    Rectangle().frame(width: 50, height: 50).overlay(Text("H\nW").foregroundColor(.black))
//                })
//
//                Button(action: { withAnimation(.easeInOut(duration: 1.0)) { self.position = 2 } }, label: {
//                    Rectangle().frame(width: 50, height: 50).overlay(Text("W H").foregroundColor(.black))
//                })
//
//                Button(action: { withAnimation(.easeInOut(duration: 1.0)) { self.position = 3 } }, label: {
//                    Rectangle().frame(width: 50, height: 50).overlay(Text("W\nH").foregroundColor(.black))
//                })
//            }
//
//        }
    }
    
    func helloH(_ d: ViewDimensions) -> CGFloat {
        if position == 0 {
            return 0
        } else if position == 1 {
            return 0
        } else if position == 2 {
            return d[.leading] - 10
        } else {
            return 0
        }
    }

    func helloV(_ d: ViewDimensions) -> CGFloat {
        if position == 0 {
            return 0
        } else if position == 1 {
            return d[.bottom] + 10
        } else if position == 2 {
            return 0
        } else {
            return d[.top] - 10
        }
    }

    func worldH(_ d: ViewDimensions) -> CGFloat {
        if position == 0 {
            return 0
        } else if position == 1 {
            return 0
        } else if position == 2 {
            return d[.trailing] + 10
        } else {
            return 0
        }
    }

    func worldV(_ d: ViewDimensions) -> CGFloat {
        if position == 0 {
            return 0
        } else if position == 1 {
            return d[.top] - 10
        } else if position == 2 {
            return 0
        } else {
            return d[.bottom] + 10
        }
    }

}

struct Hello: View {
    var body: some View {
        Group { Text("Hello").foregroundColor(.black) + Text(" World").foregroundColor(.clear) }.padding(20)
    }
}

struct World: View {
    var body: some View {
        Group { Text("Hello").foregroundColor(.clear) + Text(" World").foregroundColor(.black) }.padding(20)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
