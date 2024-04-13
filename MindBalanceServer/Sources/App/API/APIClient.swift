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
    func getEmployees() async throws {
        guard let url = URL(string: "https://randomuser.me/api/?results=5") else {
            throw APIError.malformedUrl
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard !data.isEmpty else {
            throw APIError.noData
        }
        
        guard let response = response as? HTTPURLResponse,
              response.statusCode == 200 else {
            throw APIError.badResponse
        }
        
        guard let resource = try? JSONDecoder().decode(User.APICompany.self, from: data) else {
            throw APIError.decodingFailed
        }
        
        print(resource.employees)
    }
}
