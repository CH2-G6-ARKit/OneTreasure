//
//  RiddleView.swift
//  ARIslandGame
//
//  Created by stephan on 29/05/25.
//

import SwiftUI

struct RiddleView: View {
    @ObservedObject var viewModel: RiddleViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            ShadowedRoundedBackground(width: 450, height: 280)
            
            VStack {
                VStack(spacing: 16) {
//                    Text(viewModel.currentQuestionPrompt)
//                        .foregroundColor(.dark)
//                        .font(.londrinaBody)
//                        .multilineTextAlignment(.center)
//                        .padding([.top])
                    
                    Group {
                        switch viewModel.riddleContentType {
                        case .multipleOptions:
                            multipleOptionsView
                        case .simonSaysPattern:
                            simonSaysPatternView
                        case nil:
                            Text("Loading riddle content...")
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    Button("Close") {
                        viewModel.userDismissedRiddle()
                    }
                    .padding(.top)
                    .buttonStyle(.bordered)
                }
                .frame(width: 450, height: 250)
            }
            .background(Color.accent)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.dark, lineWidth: 4)
            )
            .padding(.horizontal, 100)
            .transition(.scale.combined(with: .opacity))
            .onDisappear {
                viewModel.userDismissedRiddle()
            }
        }
    }
    
    private var multipleOptionsView: some View {
        VStack(spacing: 12) {
            if viewModel.mcBankIsCompleted {
                Text("No more questions available for the riddle.")
                    .foregroundColor(.orange)
                    .padding()
            } else {
                Text(viewModel.currentQuestionPrompt)
                    .foregroundColor(.dark)
                    .font(.londrinaBody)
                    .multilineTextAlignment(.center)
                    .padding([.top, .bottom])
                
                let fixedColumns = [
                    GridItem(.fixed(150)),
                    GridItem(.fixed(150))
                ]
                
                LazyVGrid(columns: fixedColumns, spacing: 8) {
                    ForEach(viewModel.currentOptions) { option in
                        Button(action: {
                            viewModel.mc_selectOption(optionId: option.id)
                        }) {
                            ZStack {
                                ShadowedRoundedBackground(strokeWidth: 2, width: 150, height: 50, yOffset: 4)
                                Text(option.text)
                                    .font(.londrinaBody)
                                    .frame(width: 150, height: 50)
                                    .foregroundColor(.dark)
                                    .background(.accent)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(.dark, lineWidth: 2)
                                    )
                            }
                        }
                    }
                }
            }
            
            Spacer()
        }
    }
    
    private var simonSaysPatternView: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Rounds Completed: \(viewModel.simonSays_completedRounds) / \(viewModel.simonSays_sequenceToWin)")
                    .font(.londrinaBody)
                    .foregroundColor(.dark)
                    .multilineTextAlignment(.center)
                    .padding([.top, .bottom])
            
                Text(viewModel.simonSays_feedbackMessage)
                    .font(.londrinaBody)
                    .foregroundColor(determineFeedbackColor())
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 50)
            
            if viewModel.simonSays_numberOfBoxes > 0 {
                let columnsCount = Int(ceil(sqrt(Double(viewModel.simonSays_numberOfBoxes))))
                let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: columnsCount)
                
                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(0..<viewModel.simonSays_numberOfBoxes, id: \.self) { index in
                        Button(action: {
                            if !viewModel.simonSays_isDisplayingPattern {
                                viewModel.ss_playerTappedBox(index: index)
                            }
                        }) {
                            ZStack {
                                ShadowedRoundedBackground(strokeWidth: 2, width: 60, height: 40, yOffset: 4)
                                Text("\(index + 1)")
                                    .font(.londrinaBody)
                                    .frame(width: 60, height: 40)
                                    .foregroundColor(viewModel.simonSays_currentlyHighlightedBox == index && viewModel.simonSays_isDisplayingPattern ? .accent : .dark)
                                    .background(viewModel.simonSays_currentlyHighlightedBox == index && viewModel.simonSays_isDisplayingPattern ? .dark : .accent)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(.dark, lineWidth: 2)
                                    )
                            }
                            .shadow(radius: viewModel.simonSays_currentlyHighlightedBox == index && viewModel.simonSays_isDisplayingPattern ? 5 : 2)
                            .animation(.easeInOut(duration: 0.15), value: viewModel.simonSays_currentlyHighlightedBox)
                        }
                        .disabled(viewModel.simonSays_isDisplayingPattern)
                    }
                }
                .padding(.horizontal)
            }
            
            if viewModel.simonSays_bankIsCompleted && viewModel.simonSays_completedRounds < viewModel.simonSays_sequenceToWin {
                Text("No more sequences in this challenge.")
                    .foregroundColor(.orange)
                    .padding()
            }
            Spacer()
        }
    }
    
    private func determineFeedbackColor() -> Color {
        if viewModel.simonSays_feedbackMessage.contains("Oops") || viewModel.simonSays_feedbackMessage.contains("Mismatch") {
            return .red
        } else if viewModel.simonSays_feedbackMessage.contains("Correct") {
            return .green
        }
        return .primary
    }
    
    private func determineBoxColor(for index: Int) -> Color {
        if viewModel.simonSays_currentlyHighlightedBox == index && viewModel.simonSays_isDisplayingPattern {
            return .yellow
        }
        
        return Color.blue.opacity(0.7)
    }
}

struct RiddleView_Previews: PreviewProvider {
    static var previewGameVM: GameViewModel = {
        let vm = GameViewModel()
        return vm
    }()
    
    static let preview_mcRiddle: RiddleModel = {
        let q1_opt1 = RiddleOption(id: "q1o1", text: "A Parrot")
        let q1_opt2 = RiddleOption(id: "q1o2", text: "A Treasure Chest (Correct)")
        let q1_opt3 = RiddleOption(id: "q1o3", text: "A Barrel")
        let q1_opt4 = RiddleOption(id: "q1o4", text: "A Star")
        let q1 = MultipleChoiceQuestionItem(id: "q1", itemPrompt: "What does 'X' mark on a pirate map?", options: [q1_opt1, q1_opt2, q1_opt3, q1_opt4], correctAnswerOptionsId: "q1o2")
        
        let q2_opt1 = RiddleOption(id: "q2o1", text: "Walk the Plank")
        let q2_opt2 = RiddleOption(id: "q2o2", text: "Keelhauling")
        let q2_opt3 = RiddleOption(id: "q2o3", text: "Scrub the Deck (Correct, less severe)")
        let q2 = MultipleChoiceQuestionItem(id: "q2", itemPrompt: "Which is a common punishment for minor offenses on a pirate ship?", options: [q2_opt1, q2_opt2, q2_opt3], correctAnswerOptionsId: "q2o3")
        
        let content = RiddleContent.multipleOptions(questions: [q1, q2])
        return RiddleModel(id: "preview_mc_riddle", questionText: "Pirate Code Trivia!", content: content)
    }()
    
    static let preview_ssRiddle: RiddleModel = {
        let content = RiddleContent.simonSaysPattern(
            sequence: [[0,1,2], [3,4,5], [6,7,8,0]],
            numberOfBoxes: 9,
            sequencesToWin: 2,
            presentationDurationPerElement: 0.6
        )
        return RiddleModel(id: "preview_ss_riddle", questionText: "Ancient Glyphs Challenge", content: content)
    }()
    
    static var previews: some View {
        RiddleView(viewModel: RiddleViewModel(riddle: preview_mcRiddle, gameViewModel: previewGameVM, onRiddleCompleted: { success in print("Preview MC Riddle completed: \(success)") }))
            .previewDisplayName("Multiple Options Riddle")
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
        
        RiddleView(viewModel: RiddleViewModel(riddle: preview_ssRiddle, gameViewModel: previewGameVM, onRiddleCompleted: { success in print("Preview SS Riddle completed: \(success)")}))
            .previewDisplayName("Simon Says Pattern Riddle")
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
    }
}
