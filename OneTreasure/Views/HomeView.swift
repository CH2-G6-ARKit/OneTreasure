//
//  HomeView.swift
//  ARIslandGame
//
//  Created by stephan on 21/05/25.
//

import SwiftUI

extension Image {
    func scaleImage(ratio: Double, imageName: String) -> some View {
        let uiImage = UIImage(named: imageName)!
        
        var size = uiImage.size
        size = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        return self
            .resizable()
            .frame(width: size.width, height: size.height)
    }
}

struct HomeView: View {
    @StateObject var gameVM: GameViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
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
                            gameVM.navigateToMap()
                        }) {
                            Image("playBtn")
                                .scaleImage(ratio: 0.24, imageName: "playBtn")
                        }
                    }
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(gameVM: GameViewModel())
    }
}
