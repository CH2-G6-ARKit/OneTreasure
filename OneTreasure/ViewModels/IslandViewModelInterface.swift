//
//  IslandViewModelInterface.swift
//  ARIslandGame
//
//  Created by stephan on 27/05/25.
//
import SwiftUI
import Combine
import RealityKit

protocol IslandViewModelInterface: ObservableObject {
    var island: BaseIsland { get }
    var islandName: String { get }
    var islandDescription: String { get }
    var navigationTitle: String { get }
    
    var isPaused: Bool { get set }
    
    init(islandData: BaseIsland, gameViewModel: GameViewModel)
    
    func startExperience(arView: ARView)
    func cleanUpExperience(arView: ARView)
    
    func tooglePause()
    func resumeGame()
    func exitToMap()
}
