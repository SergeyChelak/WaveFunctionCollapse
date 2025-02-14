//
//  UIFactory.swift
//  WaveFunctionCollapse
//
//  Created by Sergey on 13.02.2025.
//

import Foundation
import SwiftUI

class WFCFactory: Factory {
    private let rows = 50
    private let cols = 50
    
    private let dataSource = TileDataSource(filename: "tiles")

    func rootView() -> AnyView {
        let wfc = WaveFunctionCollapse(dataSource: dataSource, rows: rows, cols: cols)
        let viewModel = ContentViewModel(wfc: wfc)
        let view = ContentView(viewModel: viewModel)
        return AnyView(view)
    }
}
