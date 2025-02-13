//
//  DataSource.swift
//  WaveFunctionCollapse
//
//  Created by Sergey on 13.02.2025.
//

import Foundation

protocol DataSource {
    func fetchTiles() throws -> [Tile]
}
