//
//  Wfc.swift
//  WaveFunctionCollapse
//
//  Created by Sergey on 11.02.2025.
//

import Foundation
import DequeModule

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
    
    mutating func startWithRetry() -> Int {
        var attempts = 0
        while true {
            attempts += 1
            do {
                try start()
                break
            } catch {
                reset()
            }
        }
        return attempts
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
        
    func tile(for name: String) -> Tile? {
        tiles[name]
    }
            
    private mutating func start() throws {
        while let index = getFittestCellIndex() {
            // collapse picked cell
            guard let option = grid[index].options.randomElement() else {
                break
            }
            grid[index].options = [option]

            var affected: Deque<Position> = Deque(
                Position
                    .from(index: index, of: size)
                    .adjacent(in: size)
            )
            while let position = affected.popFirst() {
                let i = position.index(in: size)
                guard !grid[i].isCollapsed else {
                    continue
                }
                guard let options = updatedOptions(for: position),
                      !options.isEmpty else {
                    throw WFCError.uncollapsible
                }
                guard options.count < grid[i].options.count else {
                    continue
                }
                grid[i].options = options
                position
                    .adjacent(in: size)
                    .forEach {
                        affected.append($0)
                    }
            }
        }
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
    
    private mutating func updatedOptions(for position: Position) -> TileNameSet? {
        [
            mergedOptions(position.up) { $0.downConstraints },
            mergedOptions(position.right) { $0.leftConstraints },
            mergedOptions(position.down) { $0.upConstraints },
            mergedOptions(position.left) { $0.rightConstraints }
        ]
            .compactMap { $0 }
            .reduce(nil) { (acc: TileNameSet?, val: TileNameSet) -> TileNameSet in
                guard let acc else {
                    return val
                }
                return acc.intersection(val)
            }
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
}
