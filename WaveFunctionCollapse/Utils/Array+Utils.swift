//
//  Array+Utils.swift
//  WaveFunctionCollapse
//
//  Created by Sergey on 03.02.2025.
//

import Foundation

extension Array {
    func rotate(times: Int) -> Self {
        let step = times % count
        guard step > 0 else {
            return self
        }
        return (0..<count)
            .map {
                self[(count + $0 - times) % count]
            }
    }
}
