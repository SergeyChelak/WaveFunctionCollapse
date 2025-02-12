//
//  Wfc.swift
//  WaveFunctionCollapse
//
//  Created by Sergey on 11.02.2025.
//

import Foundation

struct Cell {
    var options: Set<TileName>
    
    var isCollapsed: Bool {
        entropy == 1
    }
    
    var entropy: Int {
        options.count
    }
}

typealias TileNameSet = Set<TileName>

struct WaveFunctionCollapse {
    private(set) var tiles: [TileName: Tile] = [:]
    private(set) var grid: [Cell] = []
    let size: Size
    private var dataSource: DataSource
    
    init(dataSource: DataSource, rows: Int, cols: Int) {
        self.dataSource = dataSource
        self.size = Size(rows: rows, cols: cols)
    }
    
    mutating func load() throws {
        let sequence = try dataSource.fetchTiles()
            .map {
                ($0.name, $0)
            }
        tiles = Dictionary(uniqueKeysWithValues: sequence)
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
                    $0.isInside(of: size) && !grid[$0.index(in: size)].isCollapsed
                }
                .forEach {
                    updateCell(at: $0)
                }
        }
    }
    
    private mutating func updateCell(at position: Position) {
        let nextOptions = [
            mergedOptions(position.up) { $0.downConstraints },
            mergedOptions(position.right) { $0.leftConstraints },
            mergedOptions(position.down) { $0.upConstraints },
            mergedOptions(position.left) { $0.rightConstraints }
        ]
            .compactMap { $0 }
            .reduce(TileNameSet()) { acc, val in
                // ???
                acc.intersection(val)
            }
        
        assert(!nextOptions.isEmpty, "intersection is empty...")
        
        grid[position.index(in: size)].options = nextOptions
    }
    
    private func mergedOptions(
        _ position: Position,
        mapper: (Tile) -> TileNameSet
    ) -> TileNameSet? {
        guard position.isInside(of: size) else {
            return nil
        }
        let cell = grid[position.index(in: size)]
        return cell.options
            .compactMap {
                tiles[$0]
            }
            .map {
                mapper($0)
            }
            .reduce(TileNameSet()) { acc, val in
                acc.union(val)
            }
    }
    
    mutating func reset() {
        self.grid = [Cell].init(
            repeating: defaultCell(),
            count: size.count
        )
    }
    
    private func defaultCell() -> Cell {
        let options = Set(tiles.keys)
        return Cell(options: options)
    }
    
    private func getFittestCellIndex() -> Int? {
        // candidate's indices with min entropy
        var indices: [Int] = []
        indices.reserveCapacity(size.count)
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
    
    func tile(for name: String) -> Tile {
        tiles[name]!
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
    
    func isInside(of size: Size) -> Bool {
        row > 0 && col > 0 && row < size.rows && col < size.cols
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
    
    var count: Int {
        rows * cols
    }
}
