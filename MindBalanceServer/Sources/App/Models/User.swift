//
//  File.swift
//  
//
//  Created by Salva Moreno on 5/4/24.
//

import Vapor
import Fluent

final class User: Model {
    // Schema
    static var schema = "users"
    
    // Properties
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "surname")
    var surname: String
    
    @Field(key: "nickname")
    var nickname: String
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "password")
    var password: String
    
    @Field(key: "dni")
    var dni: String
    
    @Field(key: "company")
    var company: String
    
    @OptionalField(key: "imageURL")
    var imageURL: String?
    
    @Field(key: "mood")
    var mood: Int
    
    @Field(key: "administrator")
    var administrator: Bool
    
    @Timestamp(key: "created_at", on: .create, format: .iso8601)
    var createdAt: Date?
    
    // Inits
    init() {}
    
    init(id: UUID? = nil, name: String, surname: String, nickname: String, email: String, password: String, dni: String, company: String, imageURL: String? = nil, mood: Int, administrator: Bool, createdAt: Date? = nil) {
        self.id = id
        self.name = name
        self.surname = surname
        self.nickname = nickname
        self.email = email
        self.password = password
        self.dni = dni
        self.company = company
        self.imageURL = imageURL
        self.mood = mood
        self.administrator = administrator
        self.createdAt = createdAt
    }
}

// DTOs
extension User {
    
//    struct Create: Content, Validatable {
//        let name: String
//        let email: String
//        let password: String
//
//        static func validations(_ validations: inout Vapor.Validations) {
//            validations.add("name", as: String.self, is: !.empty, required: true)
//            validations.add("email", as: String.self, is: .email, required: true)
//            validations.add("password", as: String.self, is: .count(6...), required: true)
//        }
//    }
    
    struct Public: Content {
        let id: UUID?
        let name: String
        let email: String
    }
}

extension User: ModelAuthenticatable {
    static var usernameKey = \User.$email
    static var passwordHashKey = \User.$password
    
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.password)
    }
}
