//
//  Order.swift
//  CoffeeOrder
//
//  Created by Martin Hrbáček on 16.12.2025.
//

import Foundation

enum CoffeeSize: String, Codable, CaseIterable {
    case small = "Small"
    case medium = "Medium"
    case large = "Large"
    
    var price: Double {
        switch self {
        case .small:
            return 50.00
        case .medium:
            return 75.00
        case .large:
            return 100.00
        }
    }
}

enum CoffeeName: String, Codable, CaseIterable {
    case espresso = "Espresso"
    case latte = "Latté"
    case cappuccino = "Cappuccino"
    case flatWhite = "Flat White"
}

struct Order: Codable, Identifiable, Hashable {
    let id: Int?
    let name: String
    let coffeeName: CoffeeName
    let total: Double
    let size: CoffeeSize
    let createdAt: String
    
    init(id: Int?, name: String, coffeeName: CoffeeName, total: Double, size: CoffeeSize, createdAt: String) {
        self.id = id
        self.name = name
        self.coffeeName = coffeeName
        self.total = total
        self.size = size
        self.createdAt = createdAt
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.coffeeName = try container.decode(CoffeeName.self, forKey: .coffeeName)
        
        let string = try container.decode(String.self, forKey: .total)
        total = Double(string) ?? 0.0
        
        self.size = try container.decode(CoffeeSize.self, forKey: .size)
        self.createdAt = try container.decode(String.self, forKey: .createdAt)
    }
}
