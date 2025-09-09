//
//  GameModel.swift
//  ARIslandGame
//
//  Created by stephan on 22/05/25.
//
import Foundation

class GameModel: ObservableObject {
    @Published var collectedFragment: Int = 0
    @Published var answerChances: Int = 3
    
    func addCollectedFragment(){
        collectedFragment += 1
    }
    
    func decreaseAnswerChances() {
        answerChances -= 1
    }
    
    func resetChances() {
        answerChances = 3
    }
}
