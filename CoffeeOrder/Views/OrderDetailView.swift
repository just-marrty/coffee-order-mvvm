//
//  OrderDetailView.swift
//  CoffeeOrder
//
//  Created by Martin Hrbáček on 16.12.2025.
//

import SwiftUI

struct OrderDetailView: View {
    
    @Environment(OrderViewModel.self) private var orderVM
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var showEditOrderView: Bool = false
    
    let order: Order
    
    var body: some View {
        Form {
            
            Text(order.name)
            Text(order.coffeeName.rawValue)
            Text(order.size.rawValue)
            Text(order.createdAt.formattedDateTime())
            Text(order.total as NSNumber, formatter: NumberFormatter.currency)
            
            HStack(spacing: 20) {
                
                Spacer()
                
                Button {
                    orderVM.startEditingOrder(order: order)
                    showEditOrderView = true
                } label: {
                    Text("Edit")
                        .font(.system(size: 18))
                }
                .buttonStyle(.borderedProminent)
                
                Button {
                    Task {
                        guard let id = order.id else { return }
                        do {
                            try await orderVM.deleteOrder(id: id)
                            dismiss()
                        } catch {
                            print("Error deleting order: \(error)")
                        }
                        
                    }
                } label: {
                    Text("Delete")
                        .font(.system(size: 18))
                        .foregroundStyle(.red)
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
            }
            .padding(5)
            //            .centerHoriontally()
        }
        .navigationTitle("Order detail")
        .navigationBarTitleDisplayMode(.inline)
        
        .sheet(isPresented: $showEditOrderView) {
            EditOrderView(order: order)
                .environment(orderVM)
        }
    }
}

#Preview {
    var config = Configuration()
    NavigationStack {
        OrderDetailView(order: Order(id: 1, name: "Martin", coffeeName: .espresso, total: (Double(75.00)), size: .medium, createdAt: "2025-12-13T09:00:00Z"))
            .environment(OrderViewModel(fetchService: FetchService(baseURL: config.environment.baseURL)))
    }
}

