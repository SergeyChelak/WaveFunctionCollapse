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
    var state: ContentViewState { get }
    var attempts: Int { get }
    var rows: Int { get }
    var cols: Int { get }
    var cells: [CellModel] { get }
    var error: Error? { get }
    func redo()
    func start()
    func load()
}

enum ContentViewState {
    case loading, processing, ready
}

class ContentViewModel: WFCViewModel {
    private var wfc: WaveFunctionCollapse
    @Published
    private(set) var error: Error?
    @Published
    private(set) var cells: [CellModel] = []
    @Published
    private(set) var state: ContentViewState = .ready
    
    private(set) var attempts: Int = 0
    
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
        self.state = .loading
        Task {
            await processWfc()
        }
    }
    
    private func processWfc() async {
        let attempts = wfc.startWithRetry()
        let result = wfc.grid
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
        Task { @MainActor in
            self.attempts = attempts
            self.cells = result
            self.state = .ready
        }
    }
    
    func load() {
        self.state = .loading
        Task {
            await loadAndStart()
        }
    }
    
    private func loadAndStart() async {
        do {
            try wfc.load()
            await processWfc()
        } catch {
            Task { @MainActor in
                self.error = error
                self.state = .ready
            }
        }
    }
}
