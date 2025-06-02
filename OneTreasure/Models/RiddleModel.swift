//
//  RiddleModel.swift
//  ARIslandGame
//
//  Created by stephan on 27/05/25.
//
import Foundation

struct RiddleOption: Codable, Identifiable {
    let id: String
    let text: String
}

struct MultipleChoiceQuestionItem: Codable, Identifiable {
    let id: String
    let itemPrompt: String
    let options: [RiddleOption]
    let correctAnswerOptionsId: String
}

enum RiddleType: String, Codable {
    case multipleOptions
    case simonSaysPattern
}

enum RiddleContent: Codable {
    case multipleOptions(
        questions: [MultipleChoiceQuestionItem]
    )
    case simonSaysPattern(
        sequence: [[Int]],
        numberOfBoxes: Int,
        sequencesToWin: Int,
        presentationDurationPerElement: Double? = 0.5
    )
    
    private enum CodingKeys: String, CodingKey {
        case type = "contentType"
        case payload
    }
    
    private enum MultipleChoiceCodingKeys: String, CodingKey {
        case questions
    }
    
    private enum SimonSaysCodingKeys: String, CodingKey {
        case sequence
        case numberOfBoxes
        case sequencesToWin
        case presentationDurationPerElement
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(RiddleType.self, forKey: .type)
        
        switch type {
        case .multipleOptions:
            let payloadContainer = try container.nestedContainer(keyedBy: MultipleChoiceCodingKeys.self, forKey: .payload)
            let questions = try payloadContainer.decode([MultipleChoiceQuestionItem].self, forKey: .questions)
            self = .multipleOptions(questions: questions)
            
        case .simonSaysPattern:
            let payloadContainer = try container.nestedContainer(keyedBy: SimonSaysCodingKeys.self, forKey: .payload)
            let sequence = try payloadContainer.decode([[Int]].self, forKey: .sequence)
            let numberOfBoxes = try payloadContainer.decode(Int.self, forKey: .numberOfBoxes)
            let sequencesToWin = try payloadContainer.decode(Int.self, forKey: .sequencesToWin)
            let duration = try payloadContainer.decode(Double.self, forKey: .presentationDurationPerElement)
            self = .simonSaysPattern(
                sequence: sequence,
                numberOfBoxes: numberOfBoxes,
                sequencesToWin: sequencesToWin,
                presentationDurationPerElement: duration ?? 0.5
            )
        }
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .multipleOptions(let questions):
            try container.encode(RiddleType.multipleOptions, forKey: .type)
            var payloadContainer = container.nestedContainer(keyedBy: MultipleChoiceCodingKeys.self, forKey: .payload)
            try payloadContainer.encode(questions, forKey: .questions)
            
        case .simonSaysPattern(let sequence, let numberOfBoxes, let sequencesToWin, let duration):
            try container.encode(RiddleType.simonSaysPattern, forKey: .type)
            var payloadContainer = container.nestedContainer(keyedBy: SimonSaysCodingKeys.self, forKey: .payload)
            try payloadContainer.encode(sequence, forKey: .sequence)
            try payloadContainer.encode(numberOfBoxes, forKey: .numberOfBoxes)
            try payloadContainer.encode(sequencesToWin, forKey: .sequencesToWin)
            try payloadContainer.encode(duration, forKey: .presentationDurationPerElement)
        }
    }
}

struct RiddleModel: Codable, Identifiable {
    let id: String
    let questionText: String
    let content: RiddleContent
}
