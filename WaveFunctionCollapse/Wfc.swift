//
//  Wfc.swift
//  WaveFunctionCollapse
//
//  Created by Sergey on 11.02.2025.
//

import Foundation

struct Cell {
    var options: [Tile]
    
//    var isCollapsed: Bool {
//        entropy == 1
//    }
    
    var entropy: Int {
        options.count
    }
}

struct WaveFunctionCollapse {
    private(set) var tiles: [Tile] = []
    private(set) var rows: Int
    private(set) var cols: Int
    private(set) var grid: [Cell] = []
    
    private var dataSource: DataSource
    
    init(dataSource: DataSource, rows: Int, cols: Int) {
        self.dataSource = dataSource
        self.rows = rows
        self.cols = cols
    }
    
    mutating func load() throws {
        self.tiles = try dataSource.fetchTiles()
        reset()
    }
            
    mutating func start() {
        while let index = getFittestCellIndex() {
            // collapse picked cell
            guard let option = grid[index].options.randomElement() else {
                break
            }
            grid[index].options = [option]
            
        
            // TODO: update adjacent cells
        }
    }
    
    mutating func reset() {
        let defaultCell = Cell(options: tiles)
        self.grid = [Cell].init(repeating: defaultCell, count: rows * cols)
    }
    
    private func getFittestCellIndex() -> Int? {
        // candidate's indices with min entropy
        var indices: [Int] = []
        for (idx, cell) in grid.enumerated() {
            let cellEntropy = cell.entropy
            guard cellEntropy > 1 else {
                continue
            }
            guard let storedIndex = indices.first else {
                indices.append(idx)
                continue
            }
            let minEntropy = grid[storedIndex].entropy
            if minEntropy == cellEntropy {
                indices.append(idx)
            } else if minEntropy < cellEntropy {
                indices.removeAll()
                indices.append(idx)
            }
        }
        return indices.randomElement()
    }
}
