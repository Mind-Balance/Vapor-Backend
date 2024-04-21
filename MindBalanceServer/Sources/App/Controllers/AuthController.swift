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
        }
    }
}

extension AuthController {
    func signIn(req: Request) async throws -> JWTToken.Public {
        // Get authenticated user
        let user: User = try req.auth.require(User.self)
        
        // TODO: Comprobar si el usuario tiene el campo de cambio de contraseña: bool
        // if false:
        //      se devuelven tokens vacíos. Al recibirlos vacíos en cliente, este le llevará a la pantalla
        //      de cambio de contraseña. Se introducen las dos contraseñas y se hace llamada POST con email, pass antigua (guardados en Keychain) y la nueva contraseña
        #warning("Ahora quedaría hacer llamada para cambiar contraseña")
        
        if user.passwordChanged {
            // Generate tokens
            let tokens = JWTToken.generateToken(userID: user.id!)
            let accessSigned = try req.jwt.sign(tokens.accessToken)
            let refreshSigned = try req.jwt.sign(tokens.refreshToken)
            
            return JWTToken.Public(accessToken: accessSigned, refreshToken: refreshSigned)
        } else {
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
}
