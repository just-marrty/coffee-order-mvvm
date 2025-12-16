//
//  AppEnvironment.swift
//  CoffeeOrder
//
//  Created by Martin Hrbáček on 16.12.2025.
//

import Foundation

enum AppEnvironment {
    case dev
    case test
    case prod
    
    var baseURL: URL {
        switch self {
        case .dev:
            return URL(string: "http://127.0.0.1:8000/")! // My own backend server. DEV URL would be different.
        case .test:
            return URL(string: "http://127.0.0.1:8000/")! // My own backend server. TEST URL would be different.
        case .prod:
            return URL(string: "http://127.0.0.1:8000/")! // My own backend server. PROD URL would be different.
        }
    }
}

enum Endpoints {
    case getOrders
    case postOrder
    case putOrder(Int)
    case deleteOrder(Int)
    
    var path: String {
        switch self {
        case .getOrders:
            return "api/orders/" // Depends on backend server requirements.
        case .postOrder:
            return "api/orders/" // Depends on backend server requirements.
        case .putOrder(let id):
            return "api/orders/\(id)/" // Depends on backend server requirements.
        case .deleteOrder(let id):
            return "api/orders/\(id)/" // Depends on backend server requirements.
        }
    }
}

struct Configuration {
    lazy var environment: AppEnvironment = {
        guard let env = ProcessInfo.processInfo.environment["ENV"] else {
            return AppEnvironment.dev
        }
        if env == "TEST" {
            return AppEnvironment.test
        }
        if env == "PROD" {
            return AppEnvironment.prod
        }
        return AppEnvironment.dev
    }()
}
