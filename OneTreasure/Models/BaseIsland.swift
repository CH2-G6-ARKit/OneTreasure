//
//  BaseIsland.swift
//  ARIslandGame
//
//  Created by stephan on 26/05/25.
//
import Foundation
import RealityKit

class BaseIsland: Codable, Identifiable{
    let id: String
    let name: String
    let descriptionText: String
    let isUnlocked: Bool
    let unlocksIslandId: String?
    let islandType: IslandType
    let awardsFragmentOrder: Int
    let islandThemeModelName: String
    
    
    init(
        id: String,
        name: String,
        descriptionText: String,
        isUnlocked: Bool,
        unlocksIslandId: String?,
        islandType: IslandType,
        awardsFragmentOrder: Int,
        islandThemeModelName: String
    ) {
        self.id = id
        self.name = name
        self.descriptionText = descriptionText
        self.isUnlocked = isUnlocked
        self.unlocksIslandId = unlocksIslandId
        self.islandType = islandType
        self.awardsFragmentOrder = awardsFragmentOrder
        self.islandThemeModelName = islandThemeModelName
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case descriptionText
        case isUnlocked
        case unlocksIslandId
        case islandType
        case awardsFragmentOrder
        case islandThemeModelName
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        descriptionText = try container.decode(String.self, forKey: .descriptionText)
        isUnlocked = try container.decode(Bool.self, forKey: .isUnlocked)
        unlocksIslandId = try container.decodeIfPresent(String.self, forKey: .unlocksIslandId)
        islandType = try container.decode(IslandType.self, forKey: .islandType)
        awardsFragmentOrder = try container.decode(Int.self, forKey: .awardsFragmentOrder)
        islandThemeModelName = try container.decode(String.self, forKey: .islandThemeModelName)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(descriptionText, forKey: .descriptionText)
        try container.encode(isUnlocked, forKey: .isUnlocked)
        try container.encodeIfPresent(unlocksIslandId, forKey: .unlocksIslandId)
        try container.encode(islandType, forKey: .islandType)
        try container.encode(awardsFragmentOrder, forKey: .awardsFragmentOrder)
        try container.encode(islandThemeModelName, forKey: .islandThemeModelName)
    }
    
    // to be overridden by subclasses
    @MainActor
    func prepareExperienceViewModel(gameViewModel: GameViewModel) -> (any IslandViewModelInterface)? {
        print("BaseIsland Warning: prepareExperienceViewModel() called. Subclass should override.")
        return nil
    }
}

