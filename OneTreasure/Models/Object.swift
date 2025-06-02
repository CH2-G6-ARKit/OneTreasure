//
//  Object.swift
//  onetreasure
//
//  Created by Stephanie Staniswinata on 20/05/25.
//

import Foundation
import SwiftData

@Model
final class Object{
    var name: String
    var question: String
    var choices: [String]
    var answer: Int
    
    init(name: String, question: String, choices: [String], answer: Int) {
        self.name = name
        self.question = question
        self.choices = choices
        self.answer = answer
    }
}
