//
//  RiddleViewModel.swift
//  ARIslandGame
//
//  Created by stephan on 28/05/25.
//
import SwiftUI
import Combine

@MainActor
class RiddleViewModel: ObservableObject {
    @Published var riddleId: String
    @Published var questionText: String
    @Published var riddleContentType: RiddleType?
    
    // for multiple options riddle
    @Published var currentQuestionPrompt: String = ""
    @Published var currentOptions: [RiddleOption] = []
    @Published var mcBankIsCompleted: Bool = false
    
    // for simon says pattern matching riddle
    @Published var simonSays_numberOfBoxes: Int = 0
    @Published var simonSays_playerInputSequence: [Int] = []
    @Published var simonSays_isDisplayingPattern: Bool = false
    @Published var simonSays_feedbackMessage: String = ""
    @Published var simonSays_completedRounds: Int = 0
    @Published var simonSays_sequenceToWin: Int = 0
    @Published var simonSays_bankIsCompleted: Bool = false
    @Published var simonSays_currentlyHighlightedBox: Int? = nil
    
    private let riddle: RiddleModel
    private weak var gameViewModel: GameViewModel?
    private var onRiddleCompleted: (Bool) -> Void
    
    private var mc_currentQuestionIndex: Int = 0
    private var mc_questionBank: [MultipleChoiceQuestionItem] = []
    
    private var ss_currentSequenceIndex: Int = 0
    private var ss_sequenceBank: [[Int]] = []
    private var ss_presentationDuration: Double = 0.5
    private var ss_currentDisplayTask: Task<Void, Never>? = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        riddle: RiddleModel,
        gameViewModel: GameViewModel,
        onRiddleCompleted: @escaping (Bool) -> Void
    ) {
        self.riddle = riddle
        self.riddleId = riddle.id
        self.gameViewModel = gameViewModel
        self.onRiddleCompleted = onRiddleCompleted
        
        self.questionText = riddle.questionText
        
        setupRiddleContent()
        restoreActiveStateAndStart()
    }
    
    deinit {
        ss_currentDisplayTask?.cancel()
    }
    
    private func setupRiddleContent() {
        switch riddle.content {
        case .multipleOptions(let questionArray):
            self.riddleContentType = .multipleOptions
            self.mc_questionBank = questionArray
            
            if mc_questionBank.isEmpty {
                mcBankIsCompleted = true
            }
            
        case .simonSaysPattern(let sequenceBank, let numberOfBoxes, let sequencesToWin, let presentationDuration):
            self.riddleContentType = .simonSaysPattern
            self.ss_sequenceBank = sequenceBank
            self.simonSays_numberOfBoxes = numberOfBoxes
            self.simonSays_sequenceToWin = sequencesToWin
            self.ss_presentationDuration = presentationDuration ?? 0.5
            
            if ss_sequenceBank.isEmpty || sequencesToWin <= 0 {
                simonSays_bankIsCompleted = true
            }
        }
    }
    
    private func restoreActiveStateAndStart() {
        if let activeState = gameViewModel?.playerProgress.activeRiddleState, activeState.riddleId == self.riddleId {
            switch riddle.content {
            case .multipleOptions:
                if let index = activeState.currentQuestionBankIndex, index < mc_questionBank.count {
                    mc_currentQuestionIndex = index
                }
            case .simonSaysPattern:
                simonSays_completedRounds = activeState.successfullyCompletedSequence ?? 0
                if let index = activeState.currentSequenceBankIndex, index < ss_sequenceBank.count {
                    ss_currentSequenceIndex = index
                }
            }
        }
        
        switch riddle.content {
        case .multipleOptions:
            if !mcBankIsCompleted {
                loadMultipleChoiceQuestion(at: mc_currentQuestionIndex)
            } else {
                onRiddleCompleted(false)
            }
        case .simonSaysPattern:
            if !simonSays_bankIsCompleted {
                startNextSimonSaysRound()
            } else {
                onRiddleCompleted(false)
            }
        }
    }
    
    private func updateActiveRiddleState() {
        guard let gameVM = gameViewModel else { return }
        var currentMCIndex: Int? = nil
        var currentSSIndex: Int? = nil
        var completedSSRounds: Int? = nil
        
        switch riddle.content {
        case .multipleOptions:
            if !mcBankIsCompleted && mc_currentQuestionIndex < mc_questionBank.count {
                currentMCIndex = mc_currentQuestionIndex
            }
        case .simonSaysPattern:
            if !simonSays_bankIsCompleted && simonSays_completedRounds < simonSays_sequenceToWin {
                currentSSIndex = ss_currentSequenceIndex
                completedSSRounds = simonSays_completedRounds
            }
            
            if currentMCIndex != nil || currentSSIndex != nil || completedSSRounds != nil {
                let newState = ActiveRiddleState(
                    riddleId: self.riddleId,
                    islandId: gameVM.playerProgress.currentIslandId ?? "",
                    currentQuestionBankIndex: currentMCIndex,
                    currentSequenceBankIndex: currentSSIndex,
                    successfullyCompletedSequence: completedSSRounds
                )
                gameVM.updateActiveRiddleState(newState)
            } else {
                gameVM.clearActiveRiddleState()
            }
        }
    }
    
    private func loadMultipleChoiceQuestion(at index: Int) {
        guard index < mc_questionBank.count else {
            mcBankIsCompleted = true
            if !mc_questionBank.isEmpty { onRiddleCompleted(false) }
            updateActiveRiddleState()
            return
        }
        let questionItem = mc_questionBank[index]
        self.currentQuestionPrompt = questionItem.itemPrompt
        self.currentOptions = questionItem.options
        self.mc_currentQuestionIndex = index
        updateActiveRiddleState()
    }
    
    func mc_selectOption(optionId: String) {
        guard mc_currentQuestionIndex < mc_questionBank.count else { return }
        let currentQuestion = mc_questionBank[mc_currentQuestionIndex]
        
        if optionId == currentQuestion.correctAnswerOptionsId {
            gameViewModel?.playerSolvedRiddleObjective(onIslandId: gameViewModel?.playerProgress.currentIslandId ?? "", riddleId: riddle.id)
            onRiddleCompleted(true)
            updateActiveRiddleState()
        } else {
            gameViewModel?.playerFailedRiddleAttempt()
            
            if (gameViewModel?.playerProgress.answerChances ?? 0) > 0 {
                mc_currentQuestionIndex += 1
                
                loadMultipleChoiceQuestion(at: mc_currentQuestionIndex)
                
            } else {
                // No lives left, GameViewModel will handle game over.
                // The onRiddleCompleted(false) will be implicitly handled by game reset or by IslandVM.
            }
        }
    }
    
    func startNextSimonSaysRound() {
        ss_currentDisplayTask?.cancel()
        
        guard ss_currentSequenceIndex < ss_sequenceBank.count,
              simonSays_completedRounds < simonSays_sequenceToWin else {
            
            if simonSays_completedRounds < simonSays_sequenceToWin && !ss_sequenceBank.isEmpty {
                simonSays_bankIsCompleted = true
                onRiddleCompleted(false)
            }
            updateActiveRiddleState()
            return
        }
        
        let sequenceForThisRound = ss_sequenceBank[ss_currentSequenceIndex]
        simonSays_playerInputSequence = []
        simonSays_isDisplayingPattern = true
        simonSays_feedbackMessage = "Watch carefully..."
        updateActiveRiddleState()
        
        
        ss_currentDisplayTask = Task {
            do {
                for (idx, element) in sequenceForThisRound.enumerated() {
                    try Task.checkCancellation()
                    self.simonSays_currentlyHighlightedBox = element
                    
                    try await Task.sleep(nanoseconds: UInt64(ss_presentationDuration * 1_000_000_000))
                    self.simonSays_currentlyHighlightedBox = nil
                    
                    if idx < sequenceForThisRound.count - 1 {
                        try await Task.sleep(nanoseconds: UInt64((ss_presentationDuration / 3) * 1_000_000_000))
                    }
                }
                try Task.checkCancellation()
                self.simonSays_isDisplayingPattern = false
                self.simonSays_feedbackMessage = "Your turn!"
            } catch is CancellationError{
                if Task.isCancelled {
                    print("Simon Says pattern display cancelled.")
                    self.simonSays_isDisplayingPattern = false
                    self.simonSays_currentlyHighlightedBox = nil
                }
            } catch {
                print("An unexpected error occured during pattern display: \(error)")
                self.simonSays_isDisplayingPattern = false
            }
        }
    }
    
    func ss_playerTappedBox(index: Int) {
        guard !simonSays_isDisplayingPattern,
              ss_currentSequenceIndex < ss_sequenceBank.count,
              simonSays_completedRounds < simonSays_sequenceToWin else { return }
        
        simonSays_playerInputSequence.append(index)
        let currentCorrectPattern = ss_sequenceBank[ss_currentSequenceIndex]
        
        let currentInputIndex = simonSays_playerInputSequence.count - 1
        
        if simonSays_playerInputSequence[currentInputIndex] != currentCorrectPattern[currentInputIndex] {
            simonSays_feedbackMessage = "Oops! Pattern Mismatch. Try this sequence again."
            gameViewModel?.playerFailedRiddleAttempt()
            
            if (gameViewModel?.playerProgress.answerChances ?? 0) > 0 {
                simonSays_playerInputSequence = []
                startNextSimonSaysRound()
            } else {
                // No lives left. GameViewModel handles game over.
            }
            return
        }
        
        if simonSays_playerInputSequence.count == currentCorrectPattern.count {
            simonSays_feedbackMessage = "Correct! Nicely done."
            simonSays_completedRounds += 1
            
            
            if simonSays_completedRounds >= simonSays_sequenceToWin {
                gameViewModel?.playerSolvedRiddleObjective(onIslandId: gameViewModel?.playerProgress.currentIslandId ?? "", riddleId: riddle.id)
                onRiddleCompleted(true)
                updateActiveRiddleState()
            } else {
                ss_currentSequenceIndex += 1
                if ss_currentSequenceIndex < ss_sequenceBank.count {
                    Task {
                        try? await Task.sleep(nanoseconds: 1_500_000_000)
                        if !Task.isCancelled { startNextSimonSaysRound() }
                    }
                } else {
                    simonSays_bankIsCompleted = true
                    onRiddleCompleted(false)
                    updateActiveRiddleState()
                }
            }
        } else {
            simonSays_feedbackMessage = "Keep going..."
        }
        updateActiveRiddleState()
    }
    
    func userDismissedRiddle() {
        ss_currentDisplayTask?.cancel()
        print("RiddleViewModel: User dismissed view. Current state saved: \(gameViewModel?.playerProgress.activeRiddleState != nil)")
    }
    
}

