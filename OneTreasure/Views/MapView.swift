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
                ToolbarItem(placement: .navigationBarTrailing){
                    Button {
                        gameVM.showPopUpFrag()
                    } label: {
                        Image("check_frag")
                            .scaleImage(ratio: 0.6, imageName: "check_frag")
//                            .padding(.top, 30)
                        }
                    .padding(.top, 30)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        gameVM.navigateToHome()
                    } label: {
                            Image("backButton")
                                .scaleImage(ratio: 0.6, imageName: "backButton")
                            Text("SELECT LEVEL")
                                .outlinedText(strokeColor: .dark, textColor: .accent, lineWidth: 3)
                                .font(.londrinaTitle)
                        }
                    .padding(.top, 30)
                }
            }
        }
        
        
    }
    
    @ViewBuilder
    private func islandRow(for island: BaseIsland) -> some View {
        let isUnlocked = gameVM.playerProgress.unlockedIslandIds.contains(island.id)
        //                let isSolved = island.awardsFragmentOrder < gameVM.playerProgress.collectedFragments
        let index = gameVM.gameData?.islands.firstIndex(where: { $0.id == island.id }) ?? 0
        
        Button(action: {
            if isUnlocked {
                gameVM.selectIsland(island)
            } else {
                print("Island \(island.name) is locked.")
            }
        }) {
            HStack(spacing: 15) {
                Image(isUnlocked ? island.id : "locked")
                    .scaleImage(ratio: 0.6, imageName: isUnlocked ? island.id : "locked")
                    .offset(y: index%2 == 1 ? 70 : -70)
                
            }
            .padding()
        }
        .buttonStyle(PlainButtonStyle())
        // if this is used then the print is locked wont' work
        .disabled(isUnlocked == false)
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
