//
//  HomeView.swift
//  ARIslandGame
//
//  Created by stephan on 21/05/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject var gameVM: GameViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Spacer()
                }
                
                ZStack{
                    Image("bg_map")
                        .resizable()
                        .scaledToFit()
                    Image("trail")
                        .scaleImage(ratio: 0.22, imageName: "trail")
                        .offset(x:-20)
                    Image("compas")
                        .scaleImage(ratio: 0.25, imageName: "compas")
                        .offset(x:220, y:90)
                    VStack{
                        Image("title")
                            .scaleImage(ratio: 0.24, imageName: "title")
                        Button(action: {
                            gameVM.userTappedPlayOnHome()
                        }) {
                            Image("playBtn")
                                .scaleImage(ratio: 0.24, imageName: "playBtn")
                        }
                    }
                    .offset(y:-10)
                }
            }
            .background(.accent)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(gameVM: GameViewModel())
    }
}
