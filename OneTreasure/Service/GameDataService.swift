//
//  GameService.swift
//  ARIslandGame
//
//  Created by stephan on 28/05/25.
//
import Foundation

class GameDataService {
    private let gameDataJSONFileName = "gameData.json"
    private let playerProgressJSONFileName = "playerProgress.json"
    
    private var documentsDirectoryURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    private var playerProgressFileURL: URL {
        documentsDirectoryURL.appendingPathComponent(playerProgressJSONFileName)
    }
    
    func loadGameData() async -> GameDataModel? {
        guard let url = Bundle.main.url(forResource: gameDataJSONFileName.replacingOccurrences(of: ".json", with: ""), withExtension: "json") else {
            print("GameDataService Error: \(gameDataJSONFileName) not found in app bundle.")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let gameData = try decoder.decode(GameDataModel.self, from: data)
            print("GameDataService: Successfully loaded gameData.json with \(gameData.islands.count) and \(gameData.riddles.count) riddles.")
            return gameData
        } catch {
            print("GameDataService Error: Failed to decode \(gameDataJSONFileName): \(error.localizedDescription)")
            print("Detailed Error: \(error)")
            return nil
        }
    }
    
    func loadPlayerProgress() -> PlayerProgressModel? {
        let fileURL = playerProgressFileURL
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("GameDataService: playerProgress.json not found. Will create a new one.")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            let progress = try decoder.decode(PlayerProgressModel.self, from: data)
            print("GameDataService: Successfully loaded playerProgress.json")
            return progress
        } catch {
            print("GameDataService Error: Failed to decode playerProgress.json: \(error.localizedDescription)")
            return nil
        }
    }
    
    func savePlayerProgress(_ progress: PlayerProgressModel) {
        let fileURL = playerProgressFileURL
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(progress)
            try data.write(to: fileURL, options: [.atomicWrite])
            print("GameDataService: Successfully saved playerProgress.json")
        } catch {
            print("GameDataService Error: Failed to save playerProgress.json: \(error.localizedDescription)")
        }
    }
}
