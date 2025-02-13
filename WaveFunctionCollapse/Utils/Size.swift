//
//  Size.swift
//  WaveFunctionCollapse
//
//  Created by Sergey on 13.02.2025.
//

import Foundation

struct Size {
    let rows: Int
    let cols: Int
    
    var count: Int {
        rows * cols
    }
}
