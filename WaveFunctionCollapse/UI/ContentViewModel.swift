//
//  ContentViewModel.swift
//  WaveFunctionCollapse
//
//  Created by Sergey on 11.02.2025.
//

import Foundation

protocol WFCViewModel: ObservableObject {
    var rows: Int { get }
    var cols: Int { get }
    var cells: [Cell] { get }
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
    private(set) var cells: [Cell] = []
    
    var rows: Int {
        wfc.rows
    }
    
    var cols: Int {
        wfc.cols
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
