//
//  NumberFormatter+Extensions.swift
//  CoffeeOrder
//
//  Created by Martin Hrbáček on 16.12.2025.
//

import Foundation

extension NumberFormatter {
    static var currency: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }
}
