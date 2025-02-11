//
//  WFCTile.swift
//  WaveFunctionCollapse
//
//  Created by Sergey on 10.02.2025.
//

enum WFCRotation: Int, CaseIterable {
    case zero, degree90, degree180, degree270
    
    static func from(_ value: Int) -> Self {
        let count = self.allCases.count
        let rawValue = value % count
        return Self(rawValue: rawValue)!
    }
    
    func rotated(_ times: Int = 1) -> Self {
        Self.from(self.rawValue + times)
    }    
}

struct WFCTile<Edge> {
    let name: TileName
    let rotation: WFCRotation
    let upEdge: Edge
    let rightEdge: Edge
    let downEdge: Edge
    let leftEdge: Edge
    
    var upConstraints: Set<TileName> = []
    var rightConstraints: Set<TileName> = []
    var downConstraints: Set<TileName> = []
    var leftConstraints: Set<TileName> = []
}

typealias Tile = WFCTile<String>
typealias TileName = String
