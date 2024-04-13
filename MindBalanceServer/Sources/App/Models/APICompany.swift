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
//    let identification: Identification
    let image: Picture
    
    enum CodingKeys: String, CodingKey {
        case name, email, login
//        case identification = "id"
        case image = "picture"
    }
}

struct Name: Decodable {
    let first, last: String
}

struct Login: Decodable {
    let username, password: String
}

//struct Identification: Decodable {
//    let identificationName: String
//    let value: String
//
//    enum CodingKeys: String, CodingKey {
//        case identificationName = "name"
//        case value
//    }
//}

struct Picture: Decodable {
    let large: String
}
