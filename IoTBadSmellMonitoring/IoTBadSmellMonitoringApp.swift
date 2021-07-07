//
//  IoTBadSmellMonitoringApp.swift
//  IoTBadSmellMonitoring
//
//  Created by KJ on 2021/05/27.
//

import SwiftUI

@main
struct IoTBadSmellMonitoringApp: App {
    @Environment(\.scenePhase) private var scenePhase
     
    var body: some Scene {
        WindowGroup {
            if UserDefaults.standard.string(forKey: "userId") == nil {
                LaunchScreen()
            }
            else {
                SmellReceptionView()
            }
        }
    }
}
