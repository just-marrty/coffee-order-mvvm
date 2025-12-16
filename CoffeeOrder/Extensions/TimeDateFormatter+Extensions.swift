//
//  TimeDateFormatter+Extensions.swift
//  CoffeeOrder
//
//  Created by Martin Hrbáček on 16.12.2025.
//

import Foundation

extension String {
    func formattedDateTime() -> String {
        
        if let date = try? Date(self, strategy: Date.ISO8601FormatStyle(includingFractionalSeconds: true)) {
            return date.formatted(date: .abbreviated, time: .shortened)
        }
        
        if let date = try? Date(self, strategy: Date.ISO8601FormatStyle()) {
            return date.formatted(date: .abbreviated, time: .shortened)
        }
        
        return self
    }
}
