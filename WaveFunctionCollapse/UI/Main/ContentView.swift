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
        (0..<viewModel.columns)
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
        VStack {
            HStack(spacing: 20) {
                TextField("Rows", text: $viewModel.inputRows)
                    .frame(maxWidth: 100)
#if os(iOS)
                    .keyboardType(.decimalPad)
#endif
                
                TextField("Cols", text: $viewModel.inputCols)
                    .frame(maxWidth: 100)
#if os(iOS)
                    .keyboardType(.decimalPad)
#endif
                Button {
                    viewModel.start()
                } label: {
                    Text("Start")
                }
            }
            
            Text("Processing time: \(viewModel.duration) sec")
        }
    }
    
    private func errorView(_ error: Error) -> some View {
        VStack {
            panelView()
            Spacer()
            Text(error.localizedDescription)
                .foregroundStyle(Color.red)
            Spacer()
        }
    }
}

#Preview {
    class MockVM: WFCViewModel {
        let duration: Int = 0
        let state: ContentViewState = .ready
        var error: Error? = nil
        var inputRows: String = ""
        var inputCols: String = ""
        let columns: Int = 0

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
