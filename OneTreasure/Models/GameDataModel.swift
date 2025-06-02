//
//  GameDataModel.swift
//  ARIslandGame
//
//  Created by stephan on 27/05/25.
//
import Foundation

struct MapFragmentInfo: Codable, Identifiable {
    let id: String
    let order: Int
    
    let name: String
    let description: String
    let imageName: String
}

struct GameDataModel: Codable {
    let islands: [BaseIsland]
    let riddles: [RiddleModel]
    let mapFragments: [MapFragmentInfo]
    
    let overallMapDisplayStages: [String]?
    
    enum CodingKeys: String, CodingKey {
        case islands, riddles, mapFragments, overallMapDisplayStages
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.riddles = try container.decode([RiddleModel].self, forKey: .riddles)
        self.mapFragments = try container.decode([MapFragmentInfo].self, forKey: .mapFragments)
        self.overallMapDisplayStages = try container.decodeIfPresent([String].self, forKey: .overallMapDisplayStages)
        
        var islandsArrayContainer = try container.nestedUnkeyedContainer(forKey: .islands)
        var decodeIslands: [BaseIsland] = []
        
        var islandTemptContainer = islandsArrayContainer
        
        while !islandTemptContainer.isAtEnd {
            
            let itemDecoder = try islandTemptContainer.superDecoder()
            
            let islandObjectKeyedContainer = try itemDecoder.container(keyedBy: BaseIsland.CodingKeys.self)
            
            let type = try islandObjectKeyedContainer.decode(IslandType.self, forKey: .islandType)
            
            let actualItemDecoderForSubclass = try islandsArrayContainer.superDecoder()
            
            switch type {
            case .dummySoundQuest:
                decodeIslands.append(try DummyIsland(from: actualItemDecoderForSubclass))
            }
        }
        self.islands = decodeIslands
    }
}

