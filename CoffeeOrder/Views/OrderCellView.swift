//
//  OrderCellView.swift
//  CoffeeOrder
//
//  Created by Martin Hrbáček on 16.12.2025.
//

import SwiftUI

struct OrderCellView: View {
    
    let order: Order
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(order.name)
                    .accessibilityIdentifier("orderNameText") // .accessibilityIdentifier slouží k jednoznačnému označení UI prvku pro automatické UI testy, aby ho testy spolehlivě našly bez závislosti na textu nebo datech
                    .bold()
                Text("\(order.coffeeName.rawValue) (\(order.size.rawValue))")
                    .accessibilityIdentifier("coffeeNameAndSizeText")
                
                Text(order.createdAt.formattedDateTime())
                    .opacity(0.5)
                
                
            }
            
            Spacer()
            
            VStack {
                Text("Price:")
                    .bold()
                Text(order.total as NSNumber, formatter: NumberFormatter.currency)
                    .accessibilityIdentifier("coffePriceText")
            }
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    OrderCellView(order: Order(id: 1, name: "Martin", coffeeName: .espresso, total: (Double(75.00)), size: .medium, createdAt: "2025-12-13T09:00:00Z"))
}
