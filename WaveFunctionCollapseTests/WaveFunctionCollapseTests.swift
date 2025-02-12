//
//  WaveFunctionCollapseTests.swift
//  WaveFunctionCollapseTests
//
//  Created by Sergey on 10.02.2025.
//

import Testing

@testable import WaveFunctionCollapse

struct WaveFunctionCollapseTests {

    @Test func rotateTile_allEqualEdges() async throws {
        let edge = "AAA"
        let tile = Tile(
            name: "0",
            filename: "0",
            rotation: .zero,
            upEdge: edge,
            rightEdge: edge,
            downEdge: edge,
            leftEdge: edge
        )
        let output = rotate(tiles: [tile])
        #expect(output.count == 1)
    }
    
    @Test func rotateTile_twoEqualEdges() async throws {
        let edgeA = "AAA"
        let edgeB = "BBB"
        let tile = Tile(
            name: "0",
            filename: "0",
            rotation: .zero,
            upEdge: edgeA,
            rightEdge: edgeB,
            downEdge: edgeA,
            leftEdge: edgeB
        )
        let output = rotate(tiles: [tile])
        #expect(output.count == 2)
    }
        
    @Test func positionConverter() async throws {
        let size = Size(rows: 7, cols: 9)
        var matrix = [Int].init(repeating: 0, count: size.count)
        var counter = 1
        for row in 0..<size.rows {
            for col in 0..<size.cols {
                let pos = Position(row: row, col: col)
                matrix[pos.index(in: size)] = counter
                counter += 1
            }
        }
        for (i, val) in matrix.enumerated() {
            #expect(i + 1 == val)
        }
    }
}
