//
//  ContentViewModel.swift
//  WaveFunctionCollapse
//
//  Created by Sergey on 11.02.2025.
//

import Foundation

protocol WFCViewModel: ObservableObject {
    var state: ContentViewState { get }
    var duration: Int { get }
    var inputRows: String { get set }
    var inputCols: String { get set }
    var columns: Int { get }
    var cells: [CellModel] { get }
    var error: Error? { get }
    func start()
    func load()
}

enum ContentViewState {
    case loading, processing, ready
}

class ContentViewModel: WFCViewModel {
    @Published
    private(set) var error: Error?
    @Published
    private(set) var cells: [CellModel] = []
    @Published
    private(set) var state: ContentViewState = .ready
    
    @Published
    var inputRows: String = ""
    @Published
    var inputCols: String = ""
    
    private(set) var columns: Int = 0

    private(set) var duration: Int = 0
    
    private let flow: MainFlow
    
    init(flow: MainFlow) {
        self.flow = flow
    }
        
    func start() {
        self.state = .ready
        self.error = nil
        do {
            try saveParameters()
        } catch {
            self.error = error
            return
        }
        self.state = .loading
        Task {
            await processWfc()
        }
    }
    
    private func processWfc() async {
        let start = Date()
        do {
            let result = try await flow.start()
            let duration = Int(Date().timeIntervalSince(start))
            Task { @MainActor in
                self.duration = duration
                self.cells = result
                self.state = .ready
            }
        } catch {
            Task { @MainActor in
                self.duration = duration
                self.error = error
            }
            return
        }
    }
    
    func load() {
        self.state = .loading
        loadParameters()
        Task {
            await setupAndStart()
        }
    }
    
    func loadParameters() {
        let params = flow.loadParameters()
        self.columns = params.cols
        self.inputRows = String(params.rows)
        self.inputCols = String(params.cols)
    }
    
    func saveParameters() throws {
        guard let r = Int(inputRows),
              let c = Int(inputCols) else {
            throw WFCError.invalidInput
        }
        let params = Parameters(
            rows: r,
            cols: c
        )
        self.columns = c
        flow.saveParameters(params)
    }
    
    private func setupAndStart() async {
        do {            
            try await flow.setup()
            await processWfc()
        } catch {
            Task { @MainActor in
                self.error = error
                self.state = .ready
            }
        }
    }
}
