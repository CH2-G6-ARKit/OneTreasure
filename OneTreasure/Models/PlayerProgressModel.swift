//
//  PlayerProgressModel.swift
//  ARIslandGame
//
//  Created by stephan on 27/05/25.
//

struct PlayerProgressModel: Codable {
    var unlockedIslandIds: Set<String>
    var collectedFragments: Int
    var answerChances: Int
    var currentIslandId: String?
    var activeRiddleState: ActiveRiddleState?
    
    static func initial(firstIslandId: String) -> PlayerProgressModel {
        return PlayerProgressModel(
            unlockedIslandIds: [firstIslandId],
            collectedFragments: 0,
            answerChances: 3,
            currentIslandId: firstIslandId,
            activeRiddleState: nil
        )
    }
    
    mutating func resetGame(firstIslandId: String) {
        self.unlockedIslandIds = [firstIslandId]
        self.collectedFragments = 0
        self.answerChances = 3
        self.currentIslandId = firstIslandId
        self.activeRiddleState = nil
    }
}

struct ActiveRiddleState: Codable {
    let riddleId: String
    let islandId: String
    
    let currentQuestionBankIndex: Int?
    
    let currentSequenceBankIndex: Int?
    let successfullyCompletedSequence: Int?
    
    init(riddleId: String, islandId: String, currentQuestionBankIndex: Int? = nil, currentSequenceBankIndex: Int? = nil, successfullyCompletedSequence: Int? = nil) {
        self.riddleId = riddleId
        self.islandId = islandId
        self.currentQuestionBankIndex = currentQuestionBankIndex
        self.currentSequenceBankIndex = currentSequenceBankIndex
        self.successfullyCompletedSequence = successfullyCompletedSequence
    }
}
