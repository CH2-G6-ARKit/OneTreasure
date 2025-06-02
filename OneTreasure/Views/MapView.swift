//
//  MapView.swift
//  ARIslandGame
//
//  Created by stephan on 21/05/25.
//

import SwiftUI

struct MapView: View {
    @ObservedObject var gameVM: GameViewModel
    
    let gemObject = Object(name: "gems", question: "2+2", choices: ["3", "4", "6", "8"], answer: 1)
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Captain's Log: Choose Your Next Destination!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    if let islands = gameVM.gameData?.islands {
                        ForEach(islands) { island in
                            islandRow(for: island)
                        }
                    } else {
                        Text("Loading map data...")
                            .padding()
                    }
                }
                .padding()
            }
            .navigationTitle("The World Map")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        gameVM.navigateToHome()
                    } label: {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                }
            }
        }
        .accentColor(.orange)
//        VStack {
//            Text("Collected Fragments: \(gameVM.playerProgress.collectedFragments) / 4")
//                .padding(20)
//            
//            NavigationLink(destination: DummyIslandView(viewModel: dummyIslandVM, gameViewModel: gameVM)
//                .ignoresSafeArea(edges: .all)
//            ) {
//                Text("This is first map")
//            }
//            
//            Text("This is second map")
//            Text("This is third map")
//            Text("This is first map")
//        }
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
                
                VStack(alignment: .leading) {
                    Text(island.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(island.descriptionText)
                        .font(.caption)
                        .lineLimit(2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
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
            return "compass"
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        let gameVM = GameViewModel()
        MapView(gameVM: gameVM)
    }
}
