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
                case .introVideo:
                    IntroVideoView(gameVM: gameVM)
                case .map:
                    MapView(gameVM: gameVM)
                        .overlay(
                            VStack{
                                if gameVM.showPopupMap && gameVM.popupType == .frag{
                                    PopUpView(showPopUp: $gameVM.showPopupMap, type: .fragment(gameVM.playerProgress.collectedFragments, true))
                                }
                            }
                        )
                case .islandExperience:
                    if let islandVM = gameVM.currentIslandViewModel {
                        switch islandVM {
                        case let volcanoIslandVM as VolcanoIslandViewModel:
                            VolcanoIslandView(viewModel: volcanoIslandVM, gameViewModel: gameVM, viewModelD: viewModelD )
                        case let moonIslandVM as MoonIslandViewModel:
                            MoonIslandView(viewModel: moonIslandVM, gameViewModel: gameVM)
                        case let jungleIslandVM as JungleIslandViewModel:
                            JungleIslandView(viewModel: jungleIslandVM, gameViewModel: gameVM)
                        case let iceIslandVM as IceIslandViewModel:
                            IceIslandView(viewModel: iceIslandVM, gameViewModel: gameVM)
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
        .overlay(
            VStack{
                if gameVM.showPopup && gameVM.popupType == .right{
                    PopUpView(showPopUp: $gameVM.showPopup, type: .right)
                }
                if gameVM.showPopup && gameVM.popupType == .wrong{
                    PopUpView(showPopUp: $gameVM.showPopup, type: .wrong(gameVM.playerProgress.answerChances))
                }
                if gameVM.showPopup && gameVM.popupType == .lost{
                    PopUpView(showPopUp: $gameVM.showPopup, type: .lost)
                }
                if gameVM.showPopup && gameVM.popupType == .frag{
                    PopUpView(showPopUp: $gameVM.showPopup, type: .fragment(gameVM.playerProgress.collectedFragments, false))
                }
                
            }
        )
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

//
//#Preview {
//    ContentView( viewModelD:  DialogViewModel)
//}

