//
//  Cell.swift
//  WaveFunctionCollapse
//
//  Created by Sergey on 13.02.2025.
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
