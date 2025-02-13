//
//  WFCTile.swift
//  WaveFunctionCollapse
//
//  Created by Sergey on 10.02.2025.
//

import Foundation

struct WFCTile<Edge> {
    let name: TileName
    let filename: String
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
