//
//  TileDataSource.swift
//  WaveFunctionCollapse
//
//  Created by Sergey on 10.02.2025.
//

import Foundation

enum WFCError: Error {
    case fileNotFound
}

protocol DataSource {
    func fetchTiles() throws -> [Tile]
}

struct TileDTO: Codable {
    let name: String
    let canRotate: Bool
    let edges: [String]
}

struct TileDataSource: DataSource {
    private let decoder = JSONDecoder()
    private let filename: String
    
    init(filename: String) {
        self.filename = filename
    }
    
    func fetchTiles() throws -> [Tile] {
        var tiles = try parseTilesInfo(from: filename, decoder: decoder)
            .map(Tile.from)
        tiles = rotate(tiles: tiles)
        setupConstrains(&tiles)
        return tiles
    }
}

func rotate(tiles: [Tile]) -> [Tile] {
    var output: [Tile] = []
    for tile in tiles {
        let array = WFCRotation.allCases
            .map {
                tile.rotated(times: $0.rawValue)
            }
        output.append(contentsOf: array)
    }
    return output
}

func setupConstrains(_ tiles: inout [Tile]) {
    let isMatchEdges = { (first: String, second: String) -> Bool  in
        first == String(second.reversed())
    }
    
    for var tile in tiles {
        for other in tiles {
            if isMatchEdges(tile.upEdge, other.downEdge) {
                tile.upConstraints.insert(other.name)
            }
            
            if isMatchEdges(tile.rightEdge, other.leftEdge) {
                tile.rightConstraints.insert(other.name)
            }
            
            if isMatchEdges(tile.downEdge, other.upEdge) {
                tile.downConstraints.insert(other.name)
            }
            
            if isMatchEdges(tile.leftEdge, other.rightEdge) {
                tile.leftConstraints.insert(other.name)
            }
        }
    }
}

fileprivate func parseTilesInfo<T: Decodable>(
    from file: String,
    type: String = "json",
    decoder: JSONDecoder
) throws -> [T] {
    guard let path = Bundle.main.path(forResource: file, ofType: type) else {
        throw WFCError.fileNotFound
    }
    let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
    let tiles = try decoder.decode([T].self, from: data)
    return tiles
}

fileprivate extension Tile {
    static func from(_ dto: TileDTO) -> Self {
        Tile(
            name: dto.name,
            rotation: .zero,
            upEdge: dto.edges[0],
            rightEdge: dto.edges[1],
            downEdge: dto.edges[2],
            leftEdge: dto.edges[3]
        )
    }
    
    func rotated(times: Int) -> Self {
        let rotation = self.rotation.rotated(times)
        let edges = [upEdge, rightEdge, downEdge, leftEdge].rotate(times: times)
        let name = modified(name: self.name, for: rotation)
        return Tile(
            name: name,
            rotation: rotation,
            upEdge: edges[0],
            rightEdge: edges[1],
            downEdge: edges[2],
            leftEdge: edges[3]
        )
    }
}

fileprivate func modified(name: String, for rotation: WFCRotation) -> String {
    let val = switch rotation {
    case .zero:
        "0"
    case .degree90:
        "90"
    case .degree180:
        "180"
    case .degree270:
        "270"
    }
    return "\(name)+\(val)"
}
