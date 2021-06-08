//
//  MainView.swift
//  IoTBadSmellMonitoring
//
//  Created by KJ on 2021/06/03.
//

import SwiftUI

struct MainView: View {
    @State private var showLaunchScreen = true
    
    var gradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(
                colors: [Color.black.opacity(0.6), Color.black.opacity(0)]
            ),
            startPoint: .bottom,
            endPoint: .top
        )
    }
    
    @State private var half = false
    @State private var dim = false
    @State private var blurRadius = false
    
    var body: some View {
        ZStack {
            Rectangle().fill(gradient)

            Image("LaunchImage")
                .resizable()
                .scaleEffect(half ? 1.0 : 0.5)
                .opacity(dim ? 1.0 : 0.2)
                
            Title2()
                .blur(radius: blurRadius ? 0 : 90)
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            self.half = true

            withAnimation(.easeInOut(duration: 2.0)) {
                
                self.dim = true
                self.blurRadius = true
            }
        }
    }
}

struct Title2: View {
    
    var gradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(
                colors: [Color.black.opacity(0.6), Color.black.opacity(0)]
            ),
            startPoint: .bottom,
            endPoint: .top
        )
    }
    
    var titleGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(
                colors: [Color.black.opacity(0.5), Color.black.opacity(0.5)]
            ),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("우리동네")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            
            HStack {
                Spacer()
                Text("악취감시")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
                Spacer()
                Spacer()
            }
        }
        .padding()
        .foregroundColor(.white)
        //.background(titleGradient)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
