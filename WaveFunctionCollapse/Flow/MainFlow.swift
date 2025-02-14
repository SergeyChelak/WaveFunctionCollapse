//
//  MainFlow.swift
//  WaveFunctionCollapse
//
//  Created by Sergey on 14.02.2025.
//

import Foundation

class MainFlow {
    private var engine = WaveFunctionCollapse()
    private let dataSource: DataSource
    private var parameters: Parameters = .default()

    init(dataSource: DataSource) {
        self.dataSource = dataSource
    }
    
    func setup() async throws {
        let tiles = try dataSource.fetchTiles()
        engine.setTiles(tiles)
    }
    
    func loadParameters() -> Parameters {
        // TODO: load from user defaults
        parameters
    }
    
    func saveParameters(_ params: Parameters) {
        // TODO: store into user defaults
        self.parameters = params
    }
    
    func start() async throws -> [CellModel] {
        engine.setSize(
            rows: parameters.rows,
            cols: parameters.cols
        )
        engine.reset()
        try engine.start()
        return engine.grid
            .map {
                .with(cell: $0, engine: engine)
            }
    }
}


fileprivate extension Parameters {
    static func `default`() -> Self {
        Self(rows: 17, cols: 28)
    }
}


fileprivate extension CellModel {
    static func with(cell: Cell, engine: WaveFunctionCollapse) -> Self {
        let count = cell.options.count
        return switch count {
        case 0:
            CellModel.invalid
        case 1:
            if let first = cell.options.first,
               let tile = engine.tile(for: first) {
                CellModel.collapsed(tile)
            } else {
                CellModel.invalid
            }
        default:
            CellModel.superposition(count)
        }
    }
}
