//
//  WaveFunctionCollapseApp.swift
//  WaveFunctionCollapse
//
//  Created by Sergey on 03.02.2025.
//

import SwiftUI

@main
struct WaveFunctionCollapseApp: App {
    let factory: Factory = WFCFactory()
    
    var body: some Scene {
        WindowGroup {
            factory.rootView()
#if os(OSX)
                .onDisappear {
                    NSApplication.shared.terminate(nil)
                }
#endif
        }
    }
}
