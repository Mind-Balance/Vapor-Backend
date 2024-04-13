//
//  File.swift
//  
//
//  Created by Salva Moreno on 13/4/24.
//

import Foundation
import Vapor

let companyExample: String = "KeepCoding"

final class Mapper {
    static func mapToUserModel(from employees: Employees) -> [User] {
        employees.map {
            // Hash the password given
            let passwordHashed = try? Bcrypt.hash($0.login.password)
            
            // Generate identification (step to be omitted in real case)
            let dni: String = generateDNI()
            
            return User(name: $0.name.first, surname: $0.name.last, nickname: $0.login.username, email: $0.email, password: passwordHashed ?? "", dni: dni, company: companyExample, imageURL: $0.image.large, mood: 0, administrator: false)
        }
    }
}

func generateDNI() -> String {
    let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    let numbers = "0123456789"
    
    var randomString = ""
    
    for _ in 0..<8 {
        let randomNumber = Int.random(in: 0..<numbers.count)
        let digit = numbers[numbers.index(numbers.startIndex, offsetBy: randomNumber)]
        randomString.append(digit)
    }
    
    let randomLetterIndex = Int.random(in: 0..<letters.count)
    let randomLetter = letters[letters.index(letters.startIndex, offsetBy: randomLetterIndex)]
    randomString.append(randomLetter)
    
    return randomString
}
