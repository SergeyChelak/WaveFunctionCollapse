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

protocol Factory {
    func rootView() -> AnyView
}

class WFCFactory: Factory {
    private let rows = 20
    private let cols = 20
    
    private let dataSource = TileDataSource(filename: "tiles")

    func rootView() -> AnyView {
        let wfc = WaveFunctionCollapse(dataSource: dataSource, rows: rows, cols: cols)
        let viewModel = ContentViewModel(wfc: wfc)
        let view = ContentView(viewModel: viewModel)
        return AnyView(view)
    }
}
