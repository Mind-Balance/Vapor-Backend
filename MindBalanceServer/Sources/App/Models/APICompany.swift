//
//  File.swift
//  
//
//  Created by Salva Moreno on 13/4/24.
//

import Foundation

typealias Employees = [Employee]

struct APICompany: Decodable {
    let employees: Employees
    
    enum CodingKeys: String, CodingKey {
        case results
    }
    
    init(from decoder: Decoder) throws {
        let results = try decoder.container(keyedBy: CodingKeys.self)
        
        self.employees = try results.decode(Employees.self, forKey: .results)
    }
}

struct Employee: Decodable {
    let name: Name
    let email: String
    let login: Login
    let image: Picture
    
    enum CodingKeys: String, CodingKey {
        case name, email, login
        case image = "picture"
    }
}

struct Name: Decodable {
    let first, last: String
}

struct Login: Decodable {
    let username, password: String
}

struct Picture: Decodable {
    let large: String
}
