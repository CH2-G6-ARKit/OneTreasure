//
//  GameViewModel.swift
//  ARIslandGame
//
//  Created by stephan on 27/05/25.
//
import Foundation
import RealityKit

@MainActor
class GameViewModel: ObservableObject {
    @Published var gameData: GameDataModel?
    @Published var playerProgress: PlayerProgressModel
    @Published var currentIslandViewModel: (any IslandViewModelInterface)? {
        didSet {
            if let islandVM = currentIslandViewModel {
                if playerProgress.currentIslandId != islandVM.island.id {
                    playerProgress.currentIslandId = islandVM.island.id
                }
            }
        }
    }
    
    @Published var currentScreen: GameScreen = .home
    
    @Published var isLoading: Bool = true
    @Published var showGameOverAlert: Bool = false
    @Published var showGameWonAlert: Bool = false
    @Published var errorMessage: String?
    
    @Published var showPopUpRight: Bool = false
    @Published var showPopUpWrong: Bool = false
    @Published var showPopUpFrag: Bool = false
    @Published var showPopUpLost: Bool = false
    
    private let dataService = GameDataService()
    private var initialIslandIdPlaceholder = "volcano_island"
    
    init() {
        if let loadedProgress = dataService.loadPlayerProgress() {
            self.playerProgress = loadedProgress
        } else {
            self.playerProgress = PlayerProgressModel.initial(firstIslandId: initialIslandIdPlaceholder)
            dataService.savePlayerProgress(self.playerProgress)
        }
        
        Task {
            await loadInitialGameData()
        }
    }
    
    private func loadInitialGameData() async {
        guard let loadedGameData = await dataService.loadGameData() else {
            errorMessage = "Critical Error: Could not load game definition files. The game cannot start."
            isLoading = false
            return
        }
        self.gameData = loadedGameData
        
        if playerProgress.currentIslandId == initialIslandIdPlaceholder ||
            loadedGameData.islands.first(where: {$0.id == playerProgress.currentIslandId}) == nil {
            if let firstPlayableIsland = loadedGameData.islands.first(where: {$0.isUnlocked}) {
                playerProgress.currentIslandId = firstPlayableIsland.id
                if playerProgress.unlockedIslandIds.isEmpty || playerProgress.unlockedIslandIds == [initialIslandIdPlaceholder] {
                    playerProgress.unlockedIslandIds = [firstPlayableIsland.id]
                }
            } else {
                errorMessage = "Critical Error: No initially unlocked island found in game data."
            }
        }
        
        if let currentId = playerProgress.currentIslandId, !playerProgress.unlockedIslandIds.contains(currentId) {
            if let firstPlayableIsland = loadedGameData.islands.first(where: {$0.isUnlocked}) {
                playerProgress.currentIslandId = firstPlayableIsland.id
            }
        }
        
        isLoading = false
        saveCurrentProgress()
    }
    
    func navigateToMap() {
        currentScreen = .map
    }
    
    func navigateToHome() {
        currentScreen = .home
        currentIslandViewModel = nil
    }
    
    func selectIsland(_ island: BaseIsland) {
        guard let gameData = gameData, playerProgress.unlockedIslandIds.contains(island.id) else {
            print("GameViewModel Error: Attempted to select a locked or non-existent island.")
            return
        }
        currentIslandViewModel?.cleanUpExperience(arView: ARView())
        
        if let newIslandVM = island.prepareExperienceViewModel(gameViewModel: self) {
            currentIslandViewModel = newIslandVM
            currentScreen = .islandExperience
        } else {
            print("GameViewModel Error: Could not prepare ViewModel for island \(island.name)")
        }
    }
    
    func exitIsland(arView: ARView) {
        currentIslandViewModel?.cleanUpExperience(arView: ARView())
        currentIslandViewModel = nil
        currentScreen = .map
        saveCurrentProgress()
    }
    
    func playerFailedRiddleAttempt() {
        guard playerProgress.answerChances > 0 else { return }
        
        playerProgress.answerChances -= 1
        print("GameViewModel: Player lost a chance. Answer chances remaining: \(playerProgress.answerChances)")
        
        showPopUpWrong = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.showPopUpWrong = false
        }
        
        if playerProgress.answerChances <= 0 {
            showPopUpLost = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showPopUpLost = false
            }
            resetGameProgressAndSave()
            showGameOverAlert = true
        } else {
            saveCurrentProgress()
        }
    }
    
    func playerSolvedRiddleObjective(onIslandId: String, riddleId: String) {
        guard let island = gameData?.islands.first(where: { $0.id == onIslandId }) else {
            print("GameViewModel Error: Island \(onIslandId) not found when trying to solve riddle objective.")
            return
        }
        showPopUpRight = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.showPopUpRight = false
        }
        
        if island.awardsFragmentOrder == playerProgress.collectedFragments {
            playerProgress.collectedFragments += 1
            print("GameViewModel: Map Fragment \(playerProgress.collectedFragments) collected!")
            
            showPopUpFrag = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.showPopUpFrag = false
            }
            
            
            if playerProgress.collectedFragments >= 4 {
                showGameWonAlert = true
            }
        }
        
        if let nextIslandToUnlock = island.unlocksIslandId {
            playerProgress.unlockedIslandIds.insert(nextIslandToUnlock)
            print("GameViewModel: Island \(nextIslandToUnlock) unlocked.")
        }
        
        clearActiveRiddleState()
    }
    
    func updateActiveRiddleState(_ newState: ActiveRiddleState?) {
        playerProgress.activeRiddleState = newState
        if newState == nil {
            print("GameViewModel: Active riddle state cleared.")
        } else {
            print("GameViewModel: Active riddle state updated for riddle \(newState!.riddleId)")
        }
        saveCurrentProgress()
    }
    
    func clearActiveRiddleState() {
        updateActiveRiddleState(nil)
    }
    
    private func resetGameProgressAndSave() {
        guard let firstPlayableIslandId = gameData?.islands.first(where:  {$0.isUnlocked})?.id else {
            print("GameViewModel Critical Error: Cannot reset game, no initial island found.")
            
            playerProgress.resetGame(firstIslandId: initialIslandIdPlaceholder)
            saveCurrentProgress()
            return
        }
        playerProgress.resetGame(firstIslandId: firstPlayableIslandId)
        print("GameViewModel: Game progress has been reset.")
        saveCurrentProgress()
        currentScreen = .home
    }
    
    func saveCurrentProgress() {
        dataService.savePlayerProgress(playerProgress)
    }
}
