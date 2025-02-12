//
//  Wfc.swift
//  WaveFunctionCollapse
//
//  Created by Sergey on 11.02.2025.
//

import Foundation

struct Cell {
    var options: [Tile]
    
    var isCollapsed: Bool {
        entropy == 1
    }
    
    var entropy: Int {
        options.count
    }
}

struct WaveFunctionCollapse {
    private(set) var tiles: [Tile] = []
    private(set) var grid: [Cell] = []
    private let size: Size
    private var dataSource: DataSource
    
    init(dataSource: DataSource, rows: Int, cols: Int) {
        self.dataSource = dataSource
        self.size = Size(rows: rows, cols: cols)
    }
    
    var rows: Int {
        size.rows
    }
    var cols: Int {
        size.cols
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
            
            // update entropy for adjacent cells
            let position: Position = .from(index: index, of: size)
            position.adjacent
                .filter {
                    $0.row > 0 && $0.col > 0 && $0.row < rows && $0.col < cols
                }
                .filter {
                    !grid[$0.index(in: size)].isCollapsed
                }
                .forEach {
                    updateCell(at: $0)
                }
        }
    }
    
    private mutating func updateCell(at position: Position) {
        // TODO: calculate entropy
//        fatalError()
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

struct Position {
    var row: Int
    var col: Int
    
    static func from(index: Int, of size: Size) -> Self {
        Self(
            row: index / size.cols,
            col: index % size.cols
        )
    }
    
    func index(in size: Size) -> Int {
        row * size.cols + col
    }
    
    var up: Self {
        Self(row: row - 1, col: col)
    }
    
    var down: Self {
        Self(row: row + 1, col: col)
    }
    
    var left: Self {
        Self(row: row, col: col - 1)
    }
    
    var right: Self {
        Self(row: row, col: col + 1)
    }
    
    var adjacent: [Position] {
        [up, down, left, right]
    }
}

struct Size {
    let rows: Int
    let cols: Int
}
