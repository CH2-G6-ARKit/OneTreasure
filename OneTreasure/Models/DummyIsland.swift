//
//  DummyIsland.swift
//  ARIslandGame
//
//  Created by stephan on 27/05/25.
//

class DummyIsland: BaseIsland {
    let chestRiddleId: String
    
    let islandThemePosition: SIMD3<Float>
    let islandThemeScale: SIMD3<Float>
    
    let chestModelFileName: String
    let chestPosition: SIMD3<Float>
    let chestScale: SIMD3<Float>
    
    let birdModelFileName: String
    let birdPosition: SIMD3<Float>
    let birdScale: SIMD3<Float>
    let birdAudioFileName: String
    
    init(
        id: String,
        name: String,
        descriptionText: String,
        isUnlocked: Bool,
        unlocksIslandId: String?,
        awardsFragmentOrder: Int,
        islandThemeModelName: String,
        
        chestRiddleId: String,
        islandThemePosition: SIMD3<Float>,
        islandThemeScale: SIMD3<Float>,
        chestModelFileName: String,
        chestPosition: SIMD3<Float>,
        chestScale: SIMD3<Float>,
        
        birdModelFileName: String,
        birdPosition: SIMD3<Float>,
        birdScale: SIMD3<Float>,
        birdAudioFileName: String
        
    ) {
        self.chestRiddleId = chestRiddleId
        self.islandThemePosition = islandThemePosition
        self.islandThemeScale = islandThemeScale
        self.chestModelFileName = chestModelFileName
        self.chestPosition = chestPosition
        self.chestScale = chestScale
        self.birdModelFileName = birdModelFileName
        self.birdPosition = birdPosition
        self.birdScale = birdScale
        self.birdAudioFileName = birdAudioFileName
        
        super.init(id: id, name: name, descriptionText: descriptionText, isUnlocked: isUnlocked, unlocksIslandId: unlocksIslandId, islandType: .dummySoundQuest, awardsFragmentOrder: awardsFragmentOrder, islandThemeModelName: islandThemeModelName)
    }
    
    private enum DummyCodingKeys: String, CodingKey {
        case chestRiddleId
        case islandThemePosition, islandThemeScale
        case chestModelFileName, chestPosition, chestScale
        case birdModelFileName, birdPosition, birdScale, birdAudioFileName
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DummyCodingKeys.self)
        chestRiddleId = try container.decode(String.self, forKey: .chestRiddleId)
        
        islandThemePosition = try  Self.decodeSIMD3Float(from: container, forKey: .islandThemePosition)
        islandThemeScale = try Self.decodeSIMD3Float(from: container, forKey: .islandThemeScale)
        
        chestModelFileName = try container.decode(String.self, forKey: .chestModelFileName)
        chestPosition = try Self.decodeSIMD3Float(from: container, forKey: .chestPosition)
        chestScale = try Self.decodeSIMD3Float(from: container, forKey: .chestScale)
        
        birdModelFileName = try container.decode(String.self, forKey: .birdModelFileName)
        birdPosition = try Self.decodeSIMD3Float(from: container, forKey: .birdPosition)
        birdScale = try Self.decodeSIMD3Float(from: container, forKey: .birdScale)
        birdAudioFileName = try container.decode(String.self, forKey: .birdAudioFileName)
        
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: any Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: DummyCodingKeys.self)
        try container.encode(chestRiddleId, forKey: .chestRiddleId)
        
        try Self.encodeSIMD3Float(islandThemePosition, to: &container, forKey: .islandThemePosition)
        try Self.encodeSIMD3Float(islandThemeScale, to: &container, forKey: .islandThemeScale)
        
        try container.encode(chestModelFileName, forKey: .chestModelFileName)
        try Self.encodeSIMD3Float(chestPosition, to: &container, forKey: .chestPosition)
        try Self.encodeSIMD3Float(chestScale, to: &container, forKey: .chestScale)
        
        try container.encode(birdModelFileName, forKey: .birdModelFileName)
        try Self.encodeSIMD3Float(birdPosition, to: &container, forKey: .birdPosition)
        try Self.encodeSIMD3Float(birdScale, to: &container, forKey: .birdScale)
        try container.encode(birdAudioFileName, forKey: .birdAudioFileName)
    }
    
    private static func decodeSIMD3Float(from container: KeyedDecodingContainer<DummyCodingKeys>, forKey key: DummyCodingKeys) throws -> SIMD3<Float> {
            let array = try container.decode([Float].self, forKey: key)
            guard array.count == 3 else {
                throw DecodingError.dataCorruptedError(forKey: key, in: container, debugDescription: "\(key.stringValue) array must contain 3 floats for SIMD3<Float>.")
            }
            return SIMD3<Float>(array[0], array[1], array[2])
        }
    
    
    private static func encodeSIMD3Float(_ value: SIMD3<Float>, to container: inout KeyedEncodingContainer<DummyCodingKeys>, forKey key: DummyCodingKeys) throws {
            try container.encode([value.x, value.y, value.z], forKey: key)
        }

    @MainActor
    override func prepareExperienceViewModel(gameViewModel: GameViewModel) -> (any IslandViewModelInterface)? {
        return DummyIslandViewModel(islandData: self, gameViewModel: gameViewModel)
    }
}
