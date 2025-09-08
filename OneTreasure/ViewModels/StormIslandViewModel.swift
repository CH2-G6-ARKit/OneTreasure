//
//  StormIslandViewModel.swift
//  ARIslandGame
//
//  Created by stepan on 28/05/25.
//

import SwiftUI
import RealityKit
import ARKit
import AVFoundation
import Combine

@MainActor
class StormIslandViewModel: IslandViewModelInterface {
    @Published var islandData: StormIsland
    @Published var currentExperienceState: StormIslandExperienceState = .initializing
    @Published var guidanceFeedback: String = "Listen carefully for the ancient rumble..."
    @Published var isChestVisibleAndInteractive: Bool = false
    @Published var riddleViewModel: RiddleViewModel? = nil
    
    @Published var chestWorldPosition: SIMD3<Float>? = nil
    
    @Published var isPaused: Bool = false
    
    var island: BaseIsland { islandData }
    var islandName: String { islandData.name }
    var islandDescription: String { islandData.descriptionText }
    var navigationTitle: String { islandData.name }
    
    private weak var gameViewModel: GameViewModel?
    private var arViewRef: ARView?
    private var cancellables = Set<AnyCancellable>()
    
    private let chestDetectionRadius: Float = 1.8
    private let strongFeedbackRadius: Float = 6.0
    
    enum StormIslandExperienceState {
        case initializing
        case searchingForChest
        case chestFound
        case presentingRiddle
        case completedSuccessfully
        case alreadyCompleted
        case failed
    }
    
    required init(islandData: BaseIsland, gameViewModel: GameViewModel) {
        guard let stormIslandData = islandData as? StormIsland else {
            fatalError("Incorrect islandData type passed to StormIslandViewModel. Expected StormIsland, got \(type(of: islandData)).")
        }
        self.islandData = stormIslandData
        self.gameViewModel = gameViewModel
        print("StormIslandVireModel initialized for: \(stormIslandData.name)")
    }
    
    func startExperience(arView: ARView) {
        self.arViewRef = arView
        
        if let gvm = gameViewModel, gvm.playerProgress.completedIslandIds.contains(islandData.id) {
            currentExperienceState = .alreadyCompleted
            guidanceFeedback = "You recall the roaring gales of this isle. The compass has already been claimed."
            isChestVisibleAndInteractive = false
        } else {
            currentExperienceState = .searchingForChest
            isChestVisibleAndInteractive = false
            guidanceFeedback = "Lightning flashes. A stormcrow circles… perhaps guiding you to something hidden."
        }
        print("StormIslandViewModel: startExperience called. State: \(currentExperienceState). Waiting for AR setup and chest world position.")
    }
    
    func cleanUpExperience(arView: ARView) {
        print("StormIslandViewModel: cleanUpExperience called for \(islandData.name).")
        self.arViewRef = nil
        self.riddleViewModel = nil
        
        cancellables.forEach{ $0.cancel() }
        cancellables.removeAll()
    }
    
    func updatePlayerPosition(_ playerPosition: SIMD3<Float>) {
        guard currentExperienceState == .searchingForChest, let targetPos = chestWorldPosition else { return }
        
        let distanceToChest = distance(playerPosition, targetPos)
        
        if distanceToChest < chestDetectionRadius {
            if !isChestVisibleAndInteractive {
                chestAreaApproached()
            }
        } else if distanceToChest < strongFeedbackRadius {
            guidanceFeedback = "The Stormcrow screeches! You are at the eye of its flight."
        } else {
            guidanceFeedback = "Heed the thunder and follow the Stormcrow’s cry..."
        }
    }
    
    func tooglePause() {
        isPaused.toggle()
        if isPaused {
            print("VolcanoIslandViewModel: Game Paused.")
        } else {
            print("VolcanoIslandViewModel: Game Resumed.")
        }
    }
    
    func resumeGame() {
        if isPaused {
            isPaused = false
            print("VolcanoIslandViewModel: Game Resumed from Pause Menu.")
        }
    }
    
    func exitToMap() {
        isPaused = false
        gameViewModel?.exitIsland(arView: arViewRef ?? ARView())
    }
    
    func setChestWorldTarget(position: SIMD3<Float>) {
        self.chestWorldPosition = position
        print("StormIslandViewModel: Chest world target position set to \(position)")
    }
    
    private func chestAreaApproached() {
        if let gvm = gameViewModel, gvm.playerProgress.completedIslandIds.contains(islandData.id) {
            currentExperienceState = .alreadyCompleted
            guidanceFeedback = "This Tempest Chest… its guiding secret has already been claimed"
            isChestVisibleAndInteractive = false
        } else {
            currentExperienceState = .chestFound
            isChestVisibleAndInteractive = true
            guidanceFeedback = "The Stormcrow’s wings lead you true! The Tempest Chest crackles before you."
        }
        print("StormIslandViewModel: Chest area approached. New state: \(currentExperienceState)")
    }
    
    func dismissRiddle() {
        riddleViewModel = nil
        
        if currentExperienceState == .presentingRiddle {
            currentExperienceState = .chestFound
            isChestVisibleAndInteractive = true
            guidanceFeedback = "The storm’s question remains unanswered. Return when you’re ready to face it again."
        }
    }
    
    func interactWithChest() {
        guard currentExperienceState == .chestFound && isChestVisibleAndInteractive else {
            if currentExperienceState == .alreadyCompleted {
                guidanceFeedback = "The chest is void, the storm’s guidance long spent."
            } else {
                print("StormIslandViewModel: Cannot interact with chest. State: \(currentExperienceState), Interactive: \(isChestVisibleAndInteractive)")
            }
            return
        }
        
        if let gvm = gameViewModel, gvm.playerProgress.completedIslandIds.contains(islandData.id) {
            currentExperienceState = .alreadyCompleted
            guidanceFeedback = "This compass has already pointed your way once before."
            isChestVisibleAndInteractive = false
            return
        }
        
        isChestVisibleAndInteractive = false
        presentRiddle()
    }
    
    private func presentRiddle() {
        guard let gameVM = self.gameViewModel,
              let riddleModel = gameVM.gameData?.riddles.first(where: { $0.id == islandData.chestRiddleId }) else {
            guidanceFeedback = "Error: The tempest’s lock is shattered by silence (Riddle data missing)."
            isChestVisibleAndInteractive = true
            currentExperienceState = .chestFound
            print("StormIslandViewModel Error: Riddle with ID \(islandData.chestRiddleId) not found for \(islandData.name).")
            return
        }
        
        currentExperienceState = .presentingRiddle
        self.riddleViewModel = RiddleViewModel(
            chances: gameVM.playerProgress.answerChances,
            riddle: riddleModel,
            gameViewModel: gameVM,
            onRiddleCompleted: { [weak self] (isCorrect: Bool) in
                self?.handleRiddleOutcome(isCorrect: isCorrect)
            }
        )
    }
    
    private func handleRiddleOutcome(isCorrect: Bool) {
        self.riddleViewModel = nil
        
        if isCorrect {
            currentExperienceState = .completedSuccessfully
            guidanceFeedback = "Glorious! The chest bursts open with lightning, unveiling a fragment of the lost map!"
            if let gvm = gameViewModel {
                if !gvm.playerProgress.completedIslandIds.contains(islandData.id) {
                    gvm.playerProgress.completedIslandIds.insert(islandData.id)
                    gvm.playerProgress.collectedFragments += 1
                }
            }

            isChestVisibleAndInteractive = false
        } else {
            if (gameViewModel?.playerProgress.answerChances ?? 0) > 0 {
                currentExperienceState = .chestFound
                isChestVisibleAndInteractive = true
                guidanceFeedback = "The Tempest Chest resists you. The riddle thunders on!"
            } else {
                currentExperienceState = .failed
                guidanceFeedback = "The storm keeps its secret close… for now."
                isChestVisibleAndInteractive = false
            }
        }
    }
}
