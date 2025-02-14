//
//  Wfc.swift
//  WaveFunctionCollapse
//
//  Created by Sergey on 11.02.2025.
//

import Foundation
import DequeModule

struct WaveFunctionCollapse {
    private struct State {
        let grid: [Cell]
        let fittestCellIndices: Set<Int>
    }
    
    private enum Mode {
        case normal, backtrack
    }
    
    private typealias TileNameSet = Set<TileName>
    
    private(set) var tiles: [TileName: Tile] = [:]
    private(set) var grid: [Cell] = []
    private(set) var size: Size = .zero
        
    public mutating func setSize(rows: Int, cols: Int) {
        self.size = Size(rows: rows, cols: cols)
    }
    
    public mutating func setTiles(_ tiles: [Tile]) {
        let sequence = tiles
            .map {
                ($0.name, $0)
            }
        self.tiles = Dictionary(uniqueKeysWithValues: sequence)
        reset()
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
    
    mutating func start() throws {
        var states: [State] = []
        var mode: Mode = .normal
        while true {
            var indices: Set<Int>
            switch mode {
            case .normal:
                indices = getFittestCellIndices()
            case .backtrack:
                guard let state = states.popLast() else {
                    throw WFCError.invalidState
                }
                guard !state.fittestCellIndices.isEmpty else {
                    continue
                }
                self.grid = state.grid
                indices = state.fittestCellIndices
                mode = .normal
            }
            
            guard let index = indices.randomElement(),
                  let option = grid[index].options.randomElement() else {
                return
            }
            
            indices.remove(index)
            let state = State(
                grid: grid,
                fittestCellIndices: indices
            )
            states.append(state)
            grid[index].options = [option]
            
            do {
                try updateAffectedCells(at: index)
            } catch {
                mode = .backtrack
            }
        }
    }
        
    private mutating func updateAffectedCells(at index: Int) throws {
        var affected: Deque<Position> = Deque(
            Position
                .from(index: index, of: size)
                .adjacent(in: size)
        )
        var seen: Set<Int> = []
        while let position = affected.popFirst() {
            let i = position.index(in: size)
            guard !seen.contains(i), !grid[i].isCollapsed else {
                continue
            }
            seen.insert(i)
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
    
    private func getFittestCellIndices() -> Set<Int> {
        // candidate's indices with min entropy
        var indices: Set<Int> = []
        for (idx, cell) in grid.enumerated() {
            let cellEntropy = cell.entropy
            guard cellEntropy > 1 else {
                continue
            }
            guard let storedIndex = indices.first else {
                indices.insert(idx)
                continue
            }
            let minEntropy = grid[storedIndex].entropy
            if minEntropy == cellEntropy {
                indices.insert(idx)
            } else if minEntropy < cellEntropy {
                indices.removeAll()
                indices.insert(idx)
            }
        }
        return indices
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
