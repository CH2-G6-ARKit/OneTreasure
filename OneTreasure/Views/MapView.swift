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
            GeometryReader{ geometry in
                ZStack{
//                    Text("Collected Fragments: \() / 4")
//                        .zIndex(1).offset(x:280, y:-160)
                    ScrollView(.horizontal, showsIndicators: false) {
                        ZStack{
                            Image("decoration")
                                .scaleImage(ratio: 0.2, imageName: "mapTrail")
                                .offset(x:-120)
                            Image("mapTrail")
                                .scaleImage(ratio: 0.22, imageName: "mapTrail")
                                .offset(x:-10)
                            HStack(spacing: 120) {
//                                ForEach(islands, id: \.self) {i in
//                                    NavigationLink(destination: IslandView().environmentObject(gameData)
//                                        .ignoresSafeArea(edges: .all)
//                                    ) {
//                                        Image("\(i)")
//                                            .scaleImage(ratio: 0.25, imageName: "\(i)")
//                                    }
//                                }
                                if let islands = gameVM.gameData?.islands {
                                    ForEach(islands) { island in
                                        islandRow(for: island)
                                    }
                                } else {
                                    Text("Loading map data...")
                                }
                            }
                        }
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .background(.accent)
            }
//            ScrollView {
//                VStack(alignment: .leading, spacing: 20) {
//                    if let islands = gameVM.gameData?.islands {
//                        ForEach(islands) { island in
//                            islandRow(for: island)
//                        }
//                    } else {
//                        Text("Loading map data...")
//                    }
//                }
//            }
            
            
            
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
                if isUnlocked {
                    Image(island.islandType.previewImageName)
                } else if !isUnlocked {
                    Image("locked")
                        .foregroundColor(.red)
                        .font(.title2)
                }
            }
            .padding()
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
