//
//  IceIslandViewModel.swift
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
class IceIslandViewModel: IslandViewModelInterface {
    @Published var islandData: IceIsland
    @Published var currentExperienceState: IceIslandExperienceState = .initializing
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
    
    enum IceIslandExperienceState {
        case initializing
        case searchingForChest
        case chestFound
        case presentingRiddle
        case completedSuccessfully
        case alreadyCompleted
        case failed
    }
    
    required init(islandData: BaseIsland, gameViewModel: GameViewModel) {
        guard let iceIslandData = islandData as? IceIsland else {
            fatalError("Incorrect islandData type passed to IceIslandViewModel. Expected IceIsland, got \(type(of: islandData)).")
        }
        self.islandData = iceIslandData
        self.gameViewModel = gameViewModel
        print("IceIslandVireModel initialized for: \(iceIslandData.name)")
    }
    
    func startExperience(arView: ARView) {
        DispatchQueue.main.async {
            self.arViewRef = arView
            
            if let gvm = self.gameViewModel, gvm.playerProgress.completedIslandIds.contains(self.islandData.id) {
                self.currentExperienceState = .alreadyCompleted
                self.guidanceFeedback = "You recall the frozen trial. The wooden cart has already been recovered."
                self.isChestVisibleAndInteractive = false
            } else {
                self.currentExperienceState = .searchingForChest
                self.isChestVisibleAndInteractive = false
                self.guidanceFeedback = "The northern wind howls… carrying with it a jingle from something lost"
            }
            print("IceIslandViewModel: startExperience called. State: \(self.currentExperienceState). Waiting for AR setup and chest world position.")
        }
    }
    
    func cleanUpExperience(arView: ARView) {
        print("IceIslandViewModel: cleanUpExperience called for \(islandData.name).")
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
            guidanceFeedback = "The Frost Reindeer’s bell rings sharp—its source is close at hand!"
        } else {
            guidanceFeedback = "Follow the fading jingle of the Frost Reindeer across the ice…"
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
        print("IceIslandViewModel: Chest world target position set to \(position)")
    }
    
    func dismissRiddle() {
        riddleViewModel = nil
        
        if currentExperienceState == .presentingRiddle {
            currentExperienceState = .chestFound
            isChestVisibleAndInteractive = true
            guidanceFeedback = "The riddle lingers, buried beneath snow. You may return when ready."
        }
    }
    
    private func chestAreaApproached() {
        if let gvm = gameViewModel, gvm.playerProgress.completedIslandIds.contains(islandData.id) {
            currentExperienceState = .alreadyCompleted
            guidanceFeedback = "This Frostbound Chest… its wonders already taken."
            isChestVisibleAndInteractive = false
        } else {
            currentExperienceState = .chestFound
            isChestVisibleAndInteractive = true
            guidanceFeedback = "The Frost Reindeer’s bells ring true! The Frostbound Chest gleams before you."
        }
        print("IceIslandViewModel: Chest area approached. New state: \(currentExperienceState)")
    }
    
    func interactWithChest() {
        guard currentExperienceState == .chestFound && isChestVisibleAndInteractive else {
            if currentExperienceState == .alreadyCompleted {
                guidanceFeedback = "The chest creaks open only to reveal cold emptiness."
            } else {
                print("IceIslandViewModel: Cannot interact with chest. State: \(currentExperienceState), Interactive: \(isChestVisibleAndInteractive)")
            }
            return
        }
        
        if let gvm = gameViewModel, gvm.playerProgress.completedIslandIds.contains(islandData.id) {
            currentExperienceState = .alreadyCompleted
            guidanceFeedback = "This prize has already been carried off on icy winds."
            isChestVisibleAndInteractive = false
            return
        }
        
        isChestVisibleAndInteractive = false
        presentRiddle()
    }
    
    private func presentRiddle() {
        guard let gameVM = self.gameViewModel,
              let riddleModel = gameVM.gameData?.riddles.first(where: { $0.id == islandData.chestRiddleId }) else {
            guidanceFeedback = "Error: The chest’s frost runes have melted away (Riddle data missing)."
            isChestVisibleAndInteractive = true
            currentExperienceState = .chestFound
            print("IceIslandViewModel Error: Riddle with ID \(islandData.chestRiddleId) not found for \(islandData.name).")
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
            guidanceFeedback = "Triumph! The chest parts with a gift—another fragment of the lost map!"
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
                guidanceFeedback = "The Frostbound Chest remains sealed. The riddle’s chill continues to bite."
            } else {
                currentExperienceState = .failed
                guidanceFeedback = "The heart of the ice keeps its mystery sealed… for now."
                isChestVisibleAndInteractive = false
            }
        }
    }
}
