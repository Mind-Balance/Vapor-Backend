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
            // Administrators
            let passwordHashed = try? Bcrypt.hash("123456")
            
            let administrator1: User = .init(name: "Manuel", surname: "Cazalla", nickname: "manuelcazalla", email: "manuelcazalla@gmail.com", password: passwordHashed ?? "", dni: generateDNI(), company: "MindBalance", imageURL: "https://randomuser.me/api/portraits/men/78.jpg", mood: 0, administrator: true, passwordChanged: false)
            let administrator2: User = .init(name: "Natalia", surname: "Camero", nickname: "nataliacamero", email: "nataliacamero@gmail.com", password: passwordHashed ?? "", dni: generateDNI(), company: "MindBalance", imageURL: "https://randomuser.me/api/portraits/women/85.jpg", mood: 0, administrator: true, passwordChanged: false)
            let administrator3: User = .init(name: "Pedro", surname: "Castellano", nickname: "pedrocastellano", email: "pedrocastellano@gmail.com", password: passwordHashed ?? "", dni: generateDNI(), company: "MindBalance", imageURL: "https://randomuser.me/api/portraits/men/78.jpg", mood: 0, administrator: true, passwordChanged: false)
            let administrator4: User = .init(name: "Natalia", surname: "Hernández", nickname: "nataliahernandez", email: "nataliahernandez@gmail.com", password: passwordHashed ?? "", dni: generateDNI(), company: "MindBalance", imageURL: "https://randomuser.me/api/portraits/women/85.jpg", mood: 0, administrator: true, passwordChanged: false)
            let administrator5: User = .init(name: "Salva", surname: "Moreno", nickname: "salvamoreno", email: "salvamoreno@gmail.com", password: passwordHashed ?? "", dni: generateDNI(), company: "MindBalance", imageURL: "https://randomuser.me/api/portraits/men/78.jpg", mood: 0, administrator: true, passwordChanged: false)
            
            let administrators: [User] = [administrator1, administrator2, administrator3, administrator4, administrator5]
            
            try await administrators.create(on: database)
            
            let employees: [User] = try await APIClient().getEmployees()
            
            print(employees)
            
            try await employees.create(on: database)
        } catch {
            print(error)
        }
    }
    
    func revert(on database: Database) async throws {
        
    }
}
