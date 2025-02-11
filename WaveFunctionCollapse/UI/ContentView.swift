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
                GridItem(.fixed(56))
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
            AnyView(gridView())
        }
    }
    
    private func gridView() -> some View {
        VStack(spacing: 20) {
            Button {
                viewModel.redo()
            } label: {
                Text("Redo")
            }
            LazyVGrid(columns: columns, spacing: 2) {
                //
            }
        }
    }
    
    private func errorView(_ error: Error) -> some View {
        Text(error.localizedDescription)
    }
}

#Preview {
    class MockVM: WFCViewModel {
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
    }
    
    let mock = MockVM()
    return ContentView(viewModel: mock)
}
