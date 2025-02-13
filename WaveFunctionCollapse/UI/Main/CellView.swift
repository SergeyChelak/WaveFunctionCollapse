//
//  CellView.swift
//  WaveFunctionCollapse
//
//  Created by Sergey on 12.02.2025.
//

import SwiftUI

struct CellView: View {
    let cell: CellModel
    
    var body: some View {
        switch cell {
        case .invalid: textView("N/A")
        case .collapsed(let tile): imageView(tile)
        case .superposition(let count): textView(String(count))
        }
    }
    
    private func textView(_ text: String) -> some View {
        Text(text)
    }
    
    private func imageView(_ tile: Tile) -> some View {
        Image(tile.filename)
            .rotationEffect(.degrees(Double(tile.rotation.degrees)))
    }
}

#Preview {
    CellView(cell: .invalid)
}
