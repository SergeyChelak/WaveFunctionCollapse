//
//  WFCRotation.swift
//  WaveFunctionCollapse
//
//  Created by Sergey on 13.02.2025.
//

import Foundation

enum WFCRotation: Int, CaseIterable {
    case zero, degree90, degree180, degree270
    
    static func from(_ value: Int) -> Self {
        let count = self.allCases.count
        let rawValue = value % count
        return Self(rawValue: rawValue)!
    }
    
    var degrees: Int {
        switch self {
        case .zero:
            0
        case .degree90:
            90
        case .degree180:
            180
        case .degree270:
            270
        }
    }
    
    func rotated(_ times: Int = 1) -> Self {
        Self.from(self.rawValue + times)
    }
}
