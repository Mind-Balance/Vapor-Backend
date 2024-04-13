//
//  File.swift
//  
//
//  Created by Salva Moreno on 13/4/24.
//

import Foundation

enum APIError: Error {
    case unknown
    case malformedUrl
    case decodingFailed
    case encodingFailed
    case badResponse
    case noData
    case statusCode(code: Int?)
}

final class APIClient {
    func getEmployees() async throws -> [User] {
        // Components
        var components = URLComponents()
        components.host = "randomuser.me"
        components.scheme = "https"
        components.path = "/api"
        components.queryItems = [URLQueryItem(name: "results", value: "15"), URLQueryItem(name: "inc", value: "name,email,login,picture")]
        
        guard let url = components.url else {
            throw APIError.malformedUrl
        }
        
        // Request
        var request = URLRequest(url: url)
        // Method
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard !data.isEmpty else {
            throw APIError.noData
        }
        
        guard let response = response as? HTTPURLResponse,
              response.statusCode == 200 else {
            throw APIError.badResponse
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: data) else {
            throw APIError.badResponse
        }
        
        print(json)
        
        guard let resource = try? JSONDecoder().decode(APICompany.self, from: data) else {
            throw APIError.decodingFailed
        }
        
        return Mapper.mapToUserModel(from: resource.employees)
    }
}
