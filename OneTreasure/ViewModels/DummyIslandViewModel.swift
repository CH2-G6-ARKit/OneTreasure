//
//  DummyViewModel.swift
//  ARIslandGame
//
//  Created by stephan on 28/05/25.
//

import SwiftUI
import RealityKit
import ARKit
import AVFoundation
import Combine

@MainActor
class DummyIslandViewModel: IslandViewModelInterface {
    @Published var islandData: DummyIsland
    @Published var currentExperienceState: DummyIslandExperienceState = .initializing
    @Published var guidanceFeedback: String = "Listen carefully for the ancient rumble..."
    @Published var isChestVisibleAndInteractive: Bool = false
    @Published var riddleViewModel: RiddleViewModel? = nil
    
    @Published var chestWorldPosition: SIMD3<Float>? = nil
    
    var island: BaseIsland { islandData }
    var islandName: String { islandData.name }
    var islandDescription: String { islandData.descriptionText }
    var navigationTitle: String { islandData.name }
    
    private weak var gameViewModel: GameViewModel?
    private var arViewRef: ARView?
    private var cancellables = Set<AnyCancellable>()
    
    private let chestDetectionRadius: Float = 1.8
    private let strongFeedbackRadius: Float = 6.0
    
    enum DummyIslandExperienceState {
        case initializing
        case searchingForChest
        case chestFound
        case presentingRiddle
        case completedSuccessfully
        case alreadyCompleted
        case failed
    }
    
    required init(islandData: BaseIsland, gameViewModel: GameViewModel) {
        guard let dummyIslandData = islandData as? DummyIsland else {
            fatalError("Incorrect islandData type passed to DummyIslandViewModel. Expected DummyIsland, got \(type(of: islandData)).")
        }
        self.islandData = dummyIslandData
        self.gameViewModel = gameViewModel
        print("DummyIslandVireModel initialized for: \(dummyIslandData.name)")
    }
    
    func startExperience(arView: ARView) {
        self.arViewRef = arView
        
        if let gvm = gameViewModel, islandData.awardsFragmentOrder < gvm.playerProgress.collectedFragments {
            currentExperienceState = .alreadyCompleted
            guidanceFeedback = "You recall the fiery trials of this place. The main treasure has been claimed."
            isChestVisibleAndInteractive = false
        } else {
            currentExperienceState = .searchingForChest
            isChestVisibleAndInteractive = false
            guidanceFeedback = "A strange bird circles above. Its call seems to echo from a hidden place..."
        }
        print("DummyIslandViewModel: startExperience called. State: \(currentExperienceState). Waiting for AR setup and chest world position.")
    }
    
    func cleanUpExperience(arView: ARView) {
        print("DummyIslandViewModel: cleanUpExperience called for \(islandData.name).")
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
            guidanceFeedback = "The Lava Falcon's cry is piercingly clear! You're right upon the source."
        } else {
            guidanceFeedback = "Follow the haunting call of the Lava Falcon..."
        }
    }
    
    func setChestWorldTarget(position: SIMD3<Float>) {
        self.chestWorldPosition = position
        print("VolcanoIslandViewModel: Chest world target position set to \(position)")
    }
    
    private func chestAreaApproached() {
        if let gvm = gameViewModel, islandData.awardsFragmentOrder < gvm.playerProgress.collectedFragments {
            currentExperienceState = .alreadyCompleted
            guidanceFeedback = "This Obsidian Chest... its main secret already yours."
            isChestVisibleAndInteractive = false
        } else {
            currentExperienceState = .chestFound
            isChestVisibleAndInteractive = true
            guidanceFeedback = "The Lava Falcon guided you true! The Obsidian Chest awaits your touch."
        }
        print("VolcanoIslandViewModel: Chest area approached. New state: \(currentExperienceState)")
    }
    
    func interactWithChest() {
        guard currentExperienceState == .chestFound && isChestVisibleAndInteractive else {
            if currentExperienceState == .alreadyCompleted {
                guidanceFeedback = "The chest is empty of its primeval magic."
            } else {
                print("VolcanoIslandViewModel: Cannot interact with chest. State: \(currentExperienceState), Interactive: \(isChestVisibleAndInteractive)")
            }
            return
        }
        
        if let gvm = gameViewModel, islandData.awardsFragmentOrder < gvm.playerProgress.collectedFragments {
            currentExperienceState = .alreadyCompleted
            guidanceFeedback = "You've claimed this prize before."
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
            print("DummyIslandViewModel Error: Riddle with ID \(islandData.chestRiddleId) not found for \(islandData.name).")
            return
        }
        
        currentExperienceState = .presentingRiddle
        self.riddleViewModel = RiddleViewModel(
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
            guidanceFeedback = "Victory! The chest opens, revealing a fragment of the lost map!"
            isChestVisibleAndInteractive = false
        } else {
            if (gameViewModel?.playerProgress.answerChances ?? 0) > 0 {
                currentExperienceState = .chestFound
                isChestVisibleAndInteractive = true
                guidanceFeedback = "The chest remains stubbornly sealed. The riddle's challenge persists!"
            } else {
                currentExperienceState = .failed
                guidanceFeedback = "The volcano's heart remains a mystery for now..."
                isChestVisibleAndInteractive = false
            }
        }
    }
}
