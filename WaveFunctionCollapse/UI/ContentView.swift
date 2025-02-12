//
//  ContentView.swift
//  WaveFunctionCollapse
//
//  Created by Sergey on 03.02.2025.
//

import SwiftUI

struct ContentView<VM: WFCViewModel>: View {
    @StateObject
    var viewModel: VM
    
    private var columns: [GridItem] {
        (0..<viewModel.cols)
            .map { _ in
                GridItem(.fixed(46))
            }
    }
    
    var body: some View {
        rootView
            .padding()
            .task {
                viewModel.load()
            }
    }
    
    private var rootView: AnyView {
        if let error = viewModel.error {
            AnyView(errorView(error))
        } else {
            switch viewModel.state {
            case .ready:
                AnyView(gridView())
            default:
                AnyView(activityView())
            }
        }
    }
    
    private func activityView() -> some View {
        VStack {
            Text("Please wait")
            ProgressView()
                .progressViewStyle(.circular)
        }
    }
    
    private func gridView() -> some View {
        VStack(spacing: 20) {
            panelView()
            ScrollView([.horizontal, .vertical], showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 0) {
                    ForEach(viewModel.cells.indices, id: \.self) {
                        CellView(cell: viewModel.cells[$0])
                    }
                }
            }
        }
    }
    
    private func panelView() -> some View {
        HStack(spacing: 50) {
            Text("Rendered after \(viewModel.attempts) attempts")
            
            Button {
                viewModel.redo()
            } label: {
                Text("Redo")
            }
        }
    }
    
    private func errorView(_ error: Error) -> some View {
        Text(error.localizedDescription)
    }
}

#Preview {
    class MockVM: WFCViewModel {
        let attempts: Int = 0
        let state: ContentViewState = .ready
        var error: Error? = nil
        
        var rows: Int {
            0
        }
        
        var cols: Int {
            0
        }
        
        func redo() {
            //
        }
        
        func start() {
            //
        }
        
        func load() {
            //
        }
        
        var cells: [CellModel] {
            []
        }
    }
    
    let mock = MockVM()
    return ContentView(viewModel: mock)
}
