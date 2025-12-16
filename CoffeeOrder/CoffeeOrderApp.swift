//
//  CoffeeOrderApp.swift
//  CoffeeOrder
//
//  Created by Martin Hrbáček on 16.12.2025.
//

import SwiftUI

@main
struct CoffeeOrderApp: App {
    
    @State private var orderVM: OrderViewModel
    
    init() {
        var config = Configuration()
        let fetchService = FetchService(baseURL: config.environment.baseURL)
        _orderVM = State(wrappedValue: OrderViewModel(fetchService: fetchService))
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(orderVM)
        }
    }
}
