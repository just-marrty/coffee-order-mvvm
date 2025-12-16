//
//  OrderViewModel.swift
//  CoffeeOrder
//
//  Created by Martin Hrbáček on 16.12.2025.
//

import Foundation
import Observation

@Observable
@MainActor
class OrderViewModel {
    var orders: [Order] = []
    
    var isLoading: Bool = false
    var errorMessage: String? = nil
    
    var name: String = ""
    var coffeeName: CoffeeName = .espresso
    var coffeeSize: CoffeeSize = .medium
    var price: Double {
        coffeeSize.price
    }
    
    var validationError: String? = nil
    var editingOrderId: Int? = nil
    
    private let fetchService: FetchService
    
    init(fetchService: FetchService) {
        self.fetchService = fetchService
    }
    
    func loadOrders() async {
        isLoading = true
        errorMessage = nil
        
        do {
            orders = try await fetchService.getOrders()
        } catch {
            errorMessage = "Cannot load the data: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    func submitOrder(order: Order) async throws {
        
        let order = Order(
            id: nil,
            name: name,
            coffeeName: coffeeName,
            total: price,
            size: coffeeSize,
            createdAt: ""
        )
        
        let newOrder = try await fetchService.postOrders(order: order)
        orders.append(newOrder)
    }
    
    func startEditingOrder(order: Order) {
        editingOrderId = order.id
        name = order.name
        coffeeName = order.coffeeName
        coffeeSize = order.size
    }
    
    func editOrder(order: Order) async throws {
        guard let id = editingOrderId else {
            fatalError("editOrder called without editingOrderId")
        }
        
        let order = Order(
            id: id,
            name: name,
            coffeeName: coffeeName,
            total: price,
            size: coffeeSize,
            createdAt: ""
        )
        
        let updateOrder = try await fetchService.putOrders(order: order)
        
        if let index = orders.firstIndex(where: { $0.id == order.id }) {
            orders[index] = updateOrder
        }
    }
    
    func deleteOrder(id: Int) async throws {
        try await fetchService.deleteOrder(id: id)
        orders.removeAll { $0.id == id }
    }
    
    func validate() -> Bool {
        validationError = nil
        
        if name.trimmingCharacters(in: .whitespaces).isEmpty {
            validationError = "Name cannot be empty!"
            return false
        }
        return true
    }
    
    func resetOrder() {
        name = ""
        coffeeName = .espresso
        coffeeSize = .medium
    }
}
