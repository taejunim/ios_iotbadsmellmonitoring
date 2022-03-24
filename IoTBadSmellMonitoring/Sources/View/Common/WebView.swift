//
//  WebView.swift
//  IoTBadSmellMonitoring
//
//  Created by KJ on 2022/03/22.
//

import SwiftUI
import WebKit

//MARK: - 웹 화면
struct WebView: UIViewRepresentable {
    var loadURL: String //호출 URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero)
        
        
        webView.navigationDelegate = nil
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.scrollView.bounces = false
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.scrollView.scrollsToTop = true
        
        if let url = URL(string: loadURL) {
            webView.load(URLRequest(url: url))
        }
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(uiWebView: self)
    }
    
    class Coordinator : NSObject {
        var webView: WebView
        
        init(uiWebView: WebView) {
            self.webView = uiWebView
        }
    }
}

struct WebView_Previews: PreviewProvider {
    static var previews: some View {
        WebView(loadURL: "")
    }
}
