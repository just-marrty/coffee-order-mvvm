//
//  AddOrderView.swift
//  CoffeeOrder
//
//  Created by Martin Hrbáček on 16.12.2025.
//

import SwiftUI

struct AddOrderView: View {
    
    @Environment(OrderViewModel.self) private var orderVM
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            @Bindable var orderVM = orderVM
            
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
                                try await orderVM.submitOrder(order: Order(id: nil, name: orderVM.name, coffeeName: orderVM.coffeeName, total: orderVM.price, size: orderVM.coffeeSize, createdAt: ""),
                                )
                                dismiss()
                            } catch {
                                print("Error creating order: \(error)")
                            }
                        }
                    }
                } label: {
                    Text("Place order")
                }
                .buttonStyle(.borderedProminent)
                
                Button {
                    orderVM.resetOrder()
                } label: {
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
    var config = Configuration()
    let orderVM = OrderViewModel(fetchService: FetchService(baseURL: config.environment.baseURL))
    
    return AddOrderView()
        .environment(orderVM)
}
