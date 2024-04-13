//
//  File.swift
//  
//
//  Created by Salva Moreno on 13/4/24.
//

import Vapor
import Fluent

struct PopulateInitialData_v0: AsyncMigration {
    func prepare(on database: Database) async throws {
        do {
            try await APIClient().getEmployees()
        } catch {
            print(error)
        }
    }
    
    func revert(on database: Database) async throws {
        
    }
}
