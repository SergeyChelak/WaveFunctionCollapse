//
//  ContentViewModel.swift
//  WaveFunctionCollapse
//
//  Created by Sergey on 11.02.2025.
//

import Foundation

enum CellModel {
    case collapsed(Tile)
    case invalid
    case superposition(Int)
}

protocol WFCViewModel: ObservableObject {
    var rows: Int { get }
    var cols: Int { get }
    var cells: [CellModel] { get }
    var error: Error? { get }
    func redo()
    func start()
    func load()
}

class ContentViewModel: WFCViewModel {
    private var wfc: WaveFunctionCollapse
    @Published
    private(set) var error: Error?
    @Published
    private(set) var cells: [CellModel] = []
    
    var rows: Int {
        wfc.size.rows
    }
    
    var cols: Int {
        wfc.size.cols
    }
    
    init(wfc: WaveFunctionCollapse) {
        self.wfc = wfc
    }
    
    func redo() {
        wfc.reset()
        start()
    }
    
    func start() {
        wfc.start()
        self.cells = wfc.grid
            .map {
                let count = $0.options.count
                return switch count {
                case 0:
                    CellModel.invalid
                case 1:
                    CellModel.collapsed(wfc.tile(for: $0.options.first!))
                default:
                    CellModel.superposition(count)
                }
            }
    }
    
    func load() {
        do {
            try wfc.load()
            start()
        } catch {
            self.error = error
        }
    }
}
