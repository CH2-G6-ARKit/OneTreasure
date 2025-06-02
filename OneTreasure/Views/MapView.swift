//
//  MapView.swift
//  ARIslandGame
//
//  Created by stephan on 21/05/25.
//

import SwiftUI

struct MapView: View {
    @ObservedObject var gameVM: GameViewModel
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
//    let islands = ["volcanoIsland", "lockedBottom", "lockedTop", "lockedBottom", "lockedTop"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if let islands = gameVM.gameData?.islands {
                        ForEach(islands) { island in
                            islandRow(for: island)
                        }
                    } else {
                        Text("Loading map data...")
                    }
                }
            }
            
            
            
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        gameVM.navigateToHome()
                    } label: {
                        ButtonView(btnType: .icon("leftArrow"))
                        Text("Go back")
                            .foregroundColor(.black)
                    }
                }
            }
        }


    }
    
    @ViewBuilder
    private func islandRow(for island: BaseIsland) -> some View {
        let isUnlocked = gameVM.playerProgress.unlockedIslandIds.contains(island.id)
        let isSolved = island.awardsFragmentOrder < gameVM.playerProgress.collectedFragments
        
        Button(action: {
            if isUnlocked {
                gameVM.selectIsland(island)
            } else {
                print("Island \(island.name) is locked.")
            }
        }) {
            HStack(spacing: 15) {
                Image(island.islandType.previewImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(RoundedRectangle(cornerRadius: 8)
                        .stroke(isUnlocked ? Color.green : Color.gray, lineWidth: 2))
                if isSolved {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                } else if !isUnlocked {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.red)
                        .font(.title2)
                }
            }
            .padding()
            .background(isUnlocked ? Color.yellow.opacity(0.2) : Color.gray.opacity(0.2))
            .cornerRadius(12)
            .opacity(isUnlocked ? 1.0 : 0.7)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isUnlocked && !isSolved)
    }
}

extension IslandType {
    var previewImageName: String {
        switch self {
        case .dummySoundQuest:
            return "compas"
        case .volcanoSoundQuest:
            return "volcano_island"
        case .moonSoundQuest:
            return "moon_island"
        case .jungleSoundQuest:
            return "jungle_island"
        case .iceSoundQuest:
            return "ice_island"
        case .stormSoundQuest:
            return "storm_island"
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        let gameVM = GameViewModel()
        MapView(gameVM: gameVM)
    }
}
