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
    var error: Error? { get }
    func redo()
    func start()
    func load()
}

class ContentViewModel: WFCViewModel {
    private var wfc: WaveFunctionCollapse
    @Published
    private(set) var error: Error?
    
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
        print("Completed")
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
