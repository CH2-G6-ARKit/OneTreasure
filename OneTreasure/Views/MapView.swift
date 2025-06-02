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
    
    var body: some View {
        NavigationView {
                ZStack{
                    Text("Collected Fragments: \(gameVM.playerProgress.collectedFragments) / 4")
                                            .zIndex(1).offset(x:280, y:-160)
                    ScrollView(.horizontal, showsIndicators: false) {
                        ZStack{
                            Image("decoration")
                                .scaleImage(ratio: 0.2, imageName: "mapTrail")
                                .offset(x:-120)
                            Image("mapTrail")
                                .scaleImage(ratio: 0.22, imageName: "mapTrail")
                                .offset(x:-10)
                            HStack(spacing: 120) {
                                if let islands = gameVM.gameData?.islands {
                                    ForEach(islands) { island in
                                        islandRow(for: island)
                                    }
                                } else {
                                    Text("Loading map data...")
                                }
                            }
                        }
                        .frame(maxHeight: 500)
                    }
                    .background(.accent)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        gameVM.navigateToHome()
                    } label: {
                        ButtonView(btnType: .icon("leftArrow"))
                        Text("SELECT LEVEL")
                            .outlinedText(strokeColor: .dark, textColor: .accent, lineWidth: 3)
                            .font(.londrinaTitle)
                    }
                    .padding(.top, 20)
                }
            }
        }
        
        
    }
    
    @ViewBuilder
    private func islandRow(for island: BaseIsland) -> some View {
        //        let isUnlocked = gameVM.playerProgress.unlockedIslandIds.contains(island.id)
        //        let isSolved = island.awardsFragmentOrder < gameVM.playerProgress.collectedFragments
        let index = gameVM.gameData?.islands.firstIndex(where: { $0.id == island.id }) ?? 0
        
        Button(action: {
            if island.isUnlocked {
                gameVM.selectIsland(island)
            } else {
                print("Island \(island.name) is locked.")
            }
        }) {
            HStack(spacing: 15) {
//                Text(String(index))
                Image(island.isUnlocked ? island.id : "locked")
                    .scaleImage(ratio: 0.6, imageName: island.isUnlocked ? island.id : "locked")
                    .offset(y: index%2 == 1 ? 70 : -70)
                
            }
            .padding()
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(island.isUnlocked == false)
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
