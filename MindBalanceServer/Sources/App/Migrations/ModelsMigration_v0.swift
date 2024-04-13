//
//  File.swift
//  
//
//  Created by Salva Moreno on 5/4/24.
//

import Vapor
import Fluent

struct ModelsMigration_v0: AsyncMigration {
    func prepare(on database: FluentKit.Database) async throws {
        try await database
            .schema(User.schema)
            .id()
            .field("name", .string, .required)
            .field("surname", .string, .required)
            .field("nickname", .string, .required)
            .field("email", .string, .required)
            .field("password", .string, .required)
            .field("dni", .string, .required)
            .field("company", .string, .required)
            .field("imageURL", .string)
            .field("mood", .int16)
            .field("administrator", .bool)
            .field("created_at", .string)
            .unique(on: "email")
            .unique(on: "dni")
            .create()
    }
    
    func revert(on database: FluentKit.Database) async throws {
        try await database.schema(User.schema).delete()
    }
}
