//
//  EditOrderView.swift
//  CoffeeOrder
//
//  Created by Martin Hrbáček on 16.12.2025.
//

import SwiftUI

struct EditOrderView: View {
    
    @Environment(OrderViewModel.self) private var orderVM
    
    @Environment(\.dismiss) private var dismiss
    
    let order: Order
    
    var body: some View {
        Form {
            @Bindable var orderVM = orderVM
            // Name field
            Text("Your name:")
            TextField("Type your name...", text: $orderVM.name)
                .accessibilityIdentifier("name")
            
            if let error = orderVM.validationError {
                Text(error)
                    .font(.system(size: 15))
                    .foregroundStyle(.red)
            }
            
            Picker("Select coffee:", selection: $orderVM.coffeeName) {
                ForEach(CoffeeName.allCases, id: \.self) { name in
                    Text(name.rawValue).tag(name)
                }
            }
            .pickerStyle(.inline)
            
            // Size picker
            Picker("Select size", selection: $orderVM.coffeeSize) {
                ForEach(CoffeeSize.allCases, id: \.rawValue) { size in
                    Text(size.rawValue).tag(size)
                }
            }
            .pickerStyle(.inline)
            
            HStack {
                Text("Price:")
                    .foregroundStyle(.secondary)
                Spacer()
                Text(orderVM.price as NSNumber, formatter: NumberFormatter.currency)
                    .font(.headline)
            }
            
            // Submit button
            HStack {
                
                Spacer()
                
                Button {
                    if orderVM.validate() {
                        Task {
                            do {
                                try await orderVM.editOrder(order: Order(id: order.id, name: orderVM.name, coffeeName: orderVM.coffeeName, total: orderVM.price, size: orderVM.coffeeSize, createdAt: ""),
                                )
                                dismiss()
                            } catch {
                                print("Error creating order: \(error)")
                            }
                        }
                    }
                } label: {
                    Text("Update order")
                }
                .buttonStyle(.borderedProminent)
                
                // test buttonu pro reset formuláře objednávky:
                Button {
                    orderVM.resetOrder()
                } label: {
                    //                    Text("Reset form")
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(.bordered)
                
                Spacer()
            }
            .padding(5)
            .accessibilityIdentifier("placeOrderButton")
        }
        .autocorrectionDisabled()
    }
}

#Preview {
    NavigationStack {
        var config = Configuration()
        EditOrderView(order: Order(id: 1, name: "Martin", coffeeName: .espresso, total: (Double(75.00)), size: .medium, createdAt: Date().formatted()))
            .environment(OrderViewModel(fetchService: FetchService(baseURL: config.environment.baseURL)))
    }
}
