//
//  MoonIslandViewModel.swift
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
class MoonIslandViewModel: IslandViewModelInterface {
    @Published var islandData: MoonIsland
    @Published var currentExperienceState: MoonIslandExperienceState = .initializing
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
    
    enum MoonIslandExperienceState {
        case initializing
        case searchingForChest
        case chestFound
        case presentingRiddle
        case completedSuccessfully
        case alreadyCompleted
        case failed
    }
    
    required init(islandData: BaseIsland, gameViewModel: GameViewModel) {
        guard let mooonIslandData = islandData as? MoonIsland else {
            fatalError("Incorrect islandData type passed to MoonIslandViewModel. Expected MoonIsland, got \(type(of: islandData)).")
        }
        self.islandData = mooonIslandData
        self.gameViewModel = gameViewModel
        print("MoonIslandViewModel initialized for: \(mooonIslandData.name)")
    }
    
    func startExperience(arView: ARView) {
        self.arViewRef = arView
        
        if let gvm = gameViewModel, gvm.playerProgress.completedIslandIds.contains(islandData.id) {
            
            currentExperienceState = .alreadyCompleted
            print("current island \(gameViewModel?.playerProgress.currentIslandId)")
            guidanceFeedback = "You remember the silent glow of Moon Island. The star has already been claimed."
            isChestVisibleAndInteractive = false
        } else {
            currentExperienceState = .searchingForChest
            isChestVisibleAndInteractive = false
            guidanceFeedback = "A silver shimmer dances in the night sky… yet the guiding star remains hidden."
        }
        print("<MoonIslandViewModel: startExperience called. State: \(currentExperienceState). Waiting for AR setup and chest world position.")
    }
    
    func cleanUpExperience(arView: ARView) {
        print("MoonIslandViewModel: cleanUpExperience called for \(islandData.name).")
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
            guidanceFeedback = "The Starlight Owl hoots above! You’re at the very edge of its luminous perch."
        } else {
            guidanceFeedback = "Seek the soft call of the Starlight Owl among the moonlit cliffs…"
        }
    }
    
    func tooglePause() {
        isPaused.toggle()
        if isPaused {
            print("MoonIslandViewModel: Game Paused.")
        } else {
            print("MoonIslandViewModel: Game Resumed.")
        }
    }
    
    func resumeGame() {
        if isPaused {
            isPaused = false
            print("MoonIslandViewModel: Game Resumed from Pause Menu.")
        }
    }
    
    func exitToMap() {
        isPaused = false
        gameViewModel?.exitIsland(arView: arViewRef ?? ARView())
    }
    
    func setChestWorldTarget(position: SIMD3<Float>) {
        self.chestWorldPosition = position
        print("MoonIslandViewModel: Chest world target position set to \(position)")
    }
    
    private func chestAreaApproached() {
        if let gvm = gameViewModel, gvm.playerProgress.completedIslandIds.contains(islandData.id) {
            currentExperienceState = .alreadyCompleted
            guidanceFeedback = "This Lunar Chest… its radiant prize is no longer here."
            isChestVisibleAndInteractive = false
        } else {
            currentExperienceState = .chestFound
            isChestVisibleAndInteractive = true
            guidanceFeedback = "The Starlight Owl has guided you well! The Lunar Chest awaits your hand."
        }
        print("MoonIslandViewModel: Chest area approached. New state: \(currentExperienceState)")
    }
    
    func dismissRiddle() {
        riddleViewModel = nil
        
        if currentExperienceState == .presentingRiddle {
            currentExperienceState = .chestFound
            isChestVisibleAndInteractive = true
            guidanceFeedback = "The riddle lingers like starlight behind clouds. Return when your mind is clear."
        }
    }
    
    func interactWithChest() {
        guard currentExperienceState == .chestFound && isChestVisibleAndInteractive else {
            if currentExperienceState == .alreadyCompleted {
                guidanceFeedback = "The chest lies hollow, its star long faded."
            } else {
                print("MoonIslandViewModel: Cannot interact with chest. State: \(currentExperienceState), Interactive: \(isChestVisibleAndInteractive)")
            }
            return
        }
        
        if let gvm = gameViewModel, gvm.playerProgress.completedIslandIds.contains(islandData.id) {
            currentExperienceState = .alreadyCompleted
            guidanceFeedback = "You’ve already drawn power from this constellation’s heart."
            isChestVisibleAndInteractive = false
            return
        }
        
        isChestVisibleAndInteractive = false
        presentRiddle()
    }
    
    private func presentRiddle() {
        guard let gameVM = self.gameViewModel,
              let riddleModel = gameVM.gameData?.riddles.first(where: { $0.id == islandData.chestRiddleId }) else {
            guidanceFeedback = "Error: The chest's ancient lock is unresponsive (Riddle data missing)."
            isChestVisibleAndInteractive = true
            currentExperienceState = .chestFound
            print("MoonIslandViewModel Error: Riddle with ID \(islandData.chestRiddleId) not found for \(islandData.name).")
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
            guidanceFeedback = "The heavens part! The chest opens, yielding a fragment of the cosmic map!"
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
                guidanceFeedback = "The Lunar Chest refuses you. The riddle still glows faintly in defiance."
            } else {
                currentExperienceState = .failed
                guidanceFeedback = "The star’s secret slips beyond your reach… for now."
                isChestVisibleAndInteractive = false
            }
        }
    }
}
