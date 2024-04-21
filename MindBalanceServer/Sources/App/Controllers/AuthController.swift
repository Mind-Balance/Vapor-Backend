//
//  File.swift
//  
//
//  Created by Salva Moreno on 5/4/24.
//

import Vapor
import Fluent

struct AuthController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        routes.group("auth") { builder in
            builder.group(User.authenticator(), User.guardMiddleware()) { builder in
                builder.get("signin", use: signIn)
            }
            builder.group(JWTToken.authenticator(), JWTToken.guardMiddleware()) { builder in
                builder.get("refresh", use: refresh)
            }
            builder.post("identity", use: identity)
        }
    }
}

extension AuthController {
    func signIn(req: Request) async throws -> JWTToken.Public {
        // Get authenticated user
        let user: User = try req.auth.require(User.self)
        
        // Check password change field
        if user.passwordChanged {
            // Generate tokens
            let tokens = JWTToken.generateToken(userID: user.id!)
            let accessSigned = try req.jwt.sign(tokens.accessToken)
            let refreshSigned = try req.jwt.sign(tokens.refreshToken)
            
            return JWTToken.Public(accessToken: accessSigned, refreshToken: refreshSigned)
        } else { // If false, returns empty tokens
            return JWTToken.Public(accessToken: "", refreshToken: "")
        }
    }
    
    func refresh(req: Request) async throws -> JWTToken.Public {
        // Get refresh token
        let token = try req.auth.require(JWTToken.self)
        
        // Verify token type
        guard token.type == .refresh else {
            throw Abort(.methodNotAllowed, reason: "Token type must be refresh type")
        }
        
        // Get user Id and find on DB
        guard let user = try await User.find(UUID(token.sub.value), on: req.db) else {
            throw Abort(.unauthorized)
        }
        
        // Generate tokens
        let tokens = JWTToken.generateToken(userID: user.id!)
        let accessSigned = try req.jwt.sign(tokens.accessToken)
        let refreshSigned = try req.jwt.sign(tokens.refreshToken)
        
        return JWTToken.Public(accessToken: accessSigned, refreshToken: refreshSigned)
    }
    
    func identity(req: Request) async throws -> JWTToken.Public {
        // Validate content entry
        try User.Identity.validate(content: req)
        
        // Decode email and dni data
        let identity = try req.content.decode(User.Identity.self)
        
        // Find user with dni on db
        guard let user = try await User
            .query(on: req.db)
            .filter(\.$dni == identity.dni)
            .first() else {
            throw Abort(.badRequest, reason: "User not authenticated: DNI not valid")
        }
        
        if user.email == identity.email {
            // Generate tokens
            let tokens = JWTToken.generateToken(userID: user.id!)
            let accessSigned = try req.jwt.sign(tokens.accessToken)
            let refreshSigned = try req.jwt.sign(tokens.refreshToken)
            
            return JWTToken.Public(accessToken: accessSigned, refreshToken: refreshSigned)
        } else {
            throw Abort(.forbidden, reason: "User not authenticated: email not valid")
        }
    }
}
