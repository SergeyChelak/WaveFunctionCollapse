//
//  CellModel.swift
//  WaveFunctionCollapse
//
//  Created by Sergey on 14.02.2025.
//

import Foundation

enum CellModel {
    case collapsed(Tile)
    case invalid
    case superposition(Int)
}
