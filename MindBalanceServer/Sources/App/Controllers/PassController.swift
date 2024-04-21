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
                builder.post("change", use: change)
            }
            builder.group(JWTToken.authenticator(), JWTToken.guardMiddleware()) { builder in
                builder.post("forgotten", use: forgotten)
            }
        }
    }
}

extension PassController {
    func change(req: Request) async throws -> JWTToken.Public {
        // Get authenticated user
        let user: User = try req.auth.require(User.self)
        
        // Validate content entry (new password)
        try User.NewPassword.validate(content: req)
        
        // Decode new password data
        let newPassword = try req.content.decode(User.NewPassword.self)
        let newPasswordHashed = try req.password.hash(newPassword.newPassword)
        
        // Find user on DB
        guard let user = try await User.find(user.id, on: req.db) else {
            throw Abort(.unauthorized)
        }
        
        // Change password to new on DB
        user.password = newPasswordHashed
        try await user.update(on: req.db)
        
        // Update password_changed to true on DB
        user.passwordChanged = true
        try await user.update(on: req.db)
        
        // Generate tokens
        let tokens = JWTToken.generateToken(userID: user.id!)
        let accessSigned = try req.jwt.sign(tokens.accessToken)
        let refreshSigned = try req.jwt.sign(tokens.refreshToken)
        
        return JWTToken.Public(accessToken: accessSigned, refreshToken: refreshSigned)
    }
    
    func forgotten(req: Request) async throws -> Bool {
        // Validate content entry
        try User.PasswordForgotten.validate(content: req)
        
        // Decode email, dni and new password data
        let passwordForgotten = try req.content.decode(User.PasswordForgotten.self)
        
        
        // Find user with dni on db
        guard let user = try await User
            .query(on: req.db)
            .filter(\.$dni == passwordForgotten.dni)
            .first() else {
            throw Abort(.badRequest, reason: "User not authenticated: DNI not valid")
        }
        
        if user.email == passwordForgotten.email {
            // Hash password
            let newPasswordHashed = try req.password.hash(passwordForgotten.newPassword)
            // Change password to new on DB
            user.password = newPasswordHashed
            try await user.update(on: req.db)
            
            return true
        } else {
            throw Abort(.forbidden, reason: "User not authenticated: email not valid")
        }
    }
}
