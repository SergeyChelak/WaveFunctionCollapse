//
//  CellView.swift
//  WaveFunctionCollapse
//
//  Created by Sergey on 12.02.2025.
//

import SwiftUI

struct CellView: View {
    let cell: Cell
    
    var body: some View {
        let count = cell.options.count
        switch count {
        case 0: textView("N/A")
        case 1: imageView(cell.options[0])
        default: textView(String(count))
        }
    }
    
    private func textView(_ text: String) -> some View {
        Text(text)
    }
    
    private func imageView(_ tile: Tile) -> some View {
        VStack {
            Text("TODO")
        }
    }
}

#Preview {
    CellView(cell: Cell(options: []))
}
