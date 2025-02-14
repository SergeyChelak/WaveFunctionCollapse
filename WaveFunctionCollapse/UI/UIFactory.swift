//
//  UIFactory.swift
//  WaveFunctionCollapse
//
//  Created by Sergey on 13.02.2025.
//

import Foundation
import SwiftUI

class WFCFactory: Factory {
    private lazy var dataSource: DataSource = {
        TileDataSource(filename: "tiles")
    }()
    
    private lazy var flow: MainFlow = {
        MainFlow(dataSource: dataSource)
    }()

    func rootView() -> AnyView {
        let viewModel = ContentViewModel(flow: flow)
        let view = ContentView(viewModel: viewModel)
        return AnyView(view)
    }
}
