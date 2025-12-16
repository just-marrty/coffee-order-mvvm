//
//  ContentView.swift
//  CoffeeOrder
//
//  Created by Martin Hrbáček on 16.12.2025.
//

import SwiftUI

struct ContentView: View {
    
    @Environment(OrderViewModel.self) private var orderVM
    @State private var showAddCoffeeView: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if orderVM.isLoading {
                    ProgressView("Loading orders...")
                        .padding()
                }
                else if let errorMessage = orderVM.errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 30))
                            .foregroundStyle(.orange)
                        
                        Text("Error")
                            .font(.headline)
                        
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button("Retry") {
                            Task {
                                await orderVM.loadOrders()
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                }
                else if orderVM.orders.isEmpty {
                    Text("No orders available!")
                        .font(.system(size: 25))
                }
                else {
                    List(orderVM.orders) { order in
                        NavigationLink(value: order) {
                            OrderCellView(order: order)
                        }
                    }
                    .listStyle(.plain)
                    .navigationDestination(for: Order.self) { order in
                        OrderDetailView(order: order)
                    }
                }
            }
            .navigationTitle("Coffe orders")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackgroundVisibility(.visible, for: .navigationBar)
            .toolbarBackgroundVisibility(.visible, for: .bottomBar)
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button("Add Order") {
                        showAddCoffeeView = true
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                }
            }
            .sheet(isPresented: $showAddCoffeeView) {
                AddOrderView()
            }
        }
        .task {
            await orderVM.loadOrders()
        }
    }
}

#Preview {
    var config = Configuration()
    ContentView().environment(OrderViewModel(fetchService: FetchService(baseURL: config.environment.baseURL)))
}
