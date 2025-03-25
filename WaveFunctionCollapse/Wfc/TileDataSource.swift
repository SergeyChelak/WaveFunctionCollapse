//
//  TileDataSource.swift
//  WaveFunctionCollapse
//
//  Created by Sergey on 10.02.2025.
//

import Foundation

fileprivate struct TileDTO: Codable {
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
        var keys: Set<TileName> = []
        var collection: [Tile] = []
        for rotation in WFCRotation.allCases {
            let rotatedTile = tile.rotated(times: rotation.rawValue)
            let key = rotatedTile.joinedEdges
            if keys.contains(key) {
                continue
            }
            keys.insert(key)
            collection.append(rotatedTile)
        }
        output.append(contentsOf: collection)
    }
    return output
}

fileprivate func setupConstrains(_ tiles: inout [Tile]) {
    let isMatchEdges = { (first: String, second: String) -> Bool  in
        first == String(second.reversed())
    }
    
    for i in tiles.indices {
        for other in tiles {
            if isMatchEdges(tiles[i].upEdge, other.downEdge) {
                tiles[i].upConstraints.insert(other.name)
            }
            
            if isMatchEdges(tiles[i].rightEdge, other.leftEdge) {
                tiles[i].rightConstraints.insert(other.name)
            }
            
            if isMatchEdges(tiles[i].downEdge, other.upEdge) {
                tiles[i].downConstraints.insert(other.name)
            }
            
            if isMatchEdges(tiles[i].leftEdge, other.rightEdge) {
                tiles[i].leftConstraints.insert(other.name)
            }
        }
        assert(!tiles[i].upConstraints.isEmpty, "up constraints are empty")
        assert(!tiles[i].downConstraints.isEmpty, "down constraints are empty")
        assert(!tiles[i].leftConstraints.isEmpty, "left constraints are empty")
        assert(!tiles[i].rightConstraints.isEmpty, "right constraints are empty")
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
            filename: dto.name,
            rotation: .zero,
            upEdge: dto.edges[0],
            rightEdge: dto.edges[1],
            downEdge: dto.edges[2],
            leftEdge: dto.edges[3]
        )
    }
    
    func rotated(times: Int) -> Self {
        let rotation = self.rotation.rotated(times)
        let edges = allEdges.rotate(times: times)
        let name = modified(name: self.name, for: rotation)
        return Tile(
            name: name,
            filename: self.filename,
            rotation: rotation,
            upEdge: edges[0],
            rightEdge: edges[1],
            downEdge: edges[2],
            leftEdge: edges[3]
        )
    }
    
    var allEdges: [TileName] {
        [upEdge, rightEdge, downEdge, leftEdge]
    }
    
    var joinedEdges: String {
        allEdges.joined(separator: "||")
    }
}

fileprivate func modified(name: String, for rotation: WFCRotation) -> String {
    let val = String(rotation.degrees)
    return "\(name)+\(val)"
}
