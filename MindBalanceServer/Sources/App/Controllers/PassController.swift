//
//  File.swift
//  
//
//  Created by Salva Moreno on 21/4/24.
//

import Vapor
import Fluent

struct PassController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        routes.group("password") { builder in
            builder.group(User.authenticator(), User.guardMiddleware()) { builder in
                builder.get("change", use: change)
            }
            builder.group(JWTToken.authenticator(), JWTToken.guardMiddleware()) { builder in
                builder.get("forgot", use: forgot)
            }
        }
    }
}

extension PassController {
    func change(req: Request) async throws -> String {
        // Get authenticated user
        let user: User = try req.auth.require(User.self)
        
        
        
        return ""
    }
    
    func forgot(req: Request) async throws -> String {
        
        
        return ""
    }
}
