//
//  FetchService.swift
//  CoffeeOrder
//
//  Created by Martin Hrbáček on 16.12.2025.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case badResponse
    case httpError(statusCode: Int)
    case decodingFail
    case encodingFail
    case missingID
}

class FetchService {
    
    private let baseURL: URL
    
    init(baseURL: URL) {
        self.baseURL = baseURL
    }
    
    // MARK: - GET
    func getOrders() async throws -> [Order] {
        guard let url = URL(string: Endpoints.getOrders.path, relativeTo: baseURL) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.badResponse
        }
        
        guard (200...299).contains(http.statusCode) else {
            throw NetworkError.httpError(statusCode: http.statusCode)
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            return try decoder.decode([Order].self, from: data)
        } catch {
            throw NetworkError.decodingFail
        }
    }
    
    // MARK: - POST
    func postOrders(order: Order) async throws -> Order {
        guard let url = URL(string: Endpoints.postOrder.path, relativeTo: baseURL) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        
        do {
            request.httpBody = try encoder.encode(order)
        } catch {
            throw NetworkError.encodingFail
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.badResponse
        }
        
        guard (200...299).contains(http.statusCode) else {
            throw NetworkError.httpError(statusCode: http.statusCode)
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            return try decoder.decode(Order.self, from: data)
        } catch {
            throw NetworkError.decodingFail
        }
    }
    
    // MARK: - PUT
    func putOrders(order: Order) async throws -> Order {
        guard let id = order.id else {
            throw NetworkError.missingID
        }
        
        guard let url = URL(string: Endpoints.putOrder(id).path, relativeTo: baseURL) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        
        do {
            request.httpBody = try encoder.encode(order)
        } catch {
            throw NetworkError.encodingFail
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.badResponse
        }
        
        guard (200...299).contains(http.statusCode) else {
            throw NetworkError.httpError(statusCode: http.statusCode)
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            return try decoder.decode(Order.self, from: data)
        } catch {
            throw NetworkError.decodingFail
        }
    }
    
    // MARK: - DELETE
    func deleteOrder(id: Int) async throws {
        guard let url = URL(string: Endpoints.deleteOrder(id).path, relativeTo: baseURL) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let (_ ,response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.badResponse
        }
        
        guard (200...299).contains(http.statusCode) else {
            throw NetworkError.httpError(statusCode: http.statusCode)
        }
    }
}
