//
//  ContentView.swift
//  ARIslandGame
//
//  Created by stephan on 20/05/25.
//

import SwiftUI
import ARKit
import RealityKit

struct ContentView: View {
    @StateObject private var gameVM = GameViewModel()
    @StateObject var viewModelD : DialogViewModel

    
    var body: some View {
        Group {
            if gameVM.isLoading && gameVM.gameData == nil {
                LoadingView()
            } else {
                switch gameVM.currentScreen {
                case .home:
                    HomeView(gameVM: gameVM)
                        .background(.accent)
                case .map:
                    MapView(gameVM: gameVM)
                case .islandExperience:
                    if let islandVM = gameVM.currentIslandViewModel {
                        switch islandVM {
                        case let volcanoIslandVM as VolcanoIslandViewModel:
                            VolcanoIslandView(viewModel: volcanoIslandVM, gameViewModel: gameVM, viewModelD: viewModelD )
                        case let moonIslandVM as MoonIslandViewModel:
                            MoonIslandView(viewModel: moonIslandVM, gameViewModel: gameVM)
//                        case let jungleIslandVM as JungleIslandViewModel:
//                            JungleIslandView(viewModel: jungleIslandVM, gameViewModel: gameVM)
//                        case let iceIslandVM as IceIslandViewModel:
//                            IceIslandView(viewModel: iceIslandVM, gameViewModel: gameVM)
                        case let stormIslandVM as StormIslandViewModel:
                            StormIslandView(viewModel: stormIslandVM, gameViewModel: gameVM)
                        default:
                            Text("Error: Unknown island type or ViewModel not set.")
                                .onAppear {
                                    gameVM.currentScreen = .map
                                }
                        }
                    } else {
                        Text("Error: No island selected.")
                            .onAppear {
                                gameVM.currentScreen = .map
                            }
                    }
                }
            }
        }
        .alert("Game Over!", isPresented: $gameVM.showGameOverAlert) {
            Button("Restart", role: .destructive) {
                gameVM.showGameOverAlert = false
            }
        } message: {
            Text("Alas, ye ran out of chances! The treasure remains lost... for now.")
        }
        .alert("Victory!", isPresented: $gameVM.showGameWonAlert) {
            Button("New Adventure") {
                gameVM.navigateToMap()
                gameVM.showGameWonAlert = false
            }
        } message: {
            Text("Huzzah! Ye've found all the fragments and located yer ship! The seas be yers once more!")
        }
        .alert("Error", isPresented: .constant(gameVM.errorMessage != nil), actions: {
            Button("OK") {
                gameVM.errorMessage = nil
            }
        }, message: {
            Text(gameVM.errorMessage ?? "An unknown error occured.")
        })
    }
}

struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                .scaleEffect(2.0, anchor: .center)
            Text("Loading Ancient Maps...")
                .font(.title3)
                .padding(.top)
                .foregroundColor(.gray)
        }
    }
}

//#Preview {
//    ContentView()
//}
