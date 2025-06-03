//
//  IntroVideoView.swift
//  OneTreasure
//
//  Created by stephan on 03/06/25.
//

import SwiftUI
import AVKit


struct IntroVideoView: View {
    @ObservedObject var gameVM: GameViewModel
    private var player: AVPlayer
    
    init(gameVM: GameViewModel) {
        self.gameVM = gameVM
        if let url = Bundle.main.url(forResource: "IntroVideo", withExtension: "MP4") {
            self.player = AVPlayer(url: url)
        } else {
            print("Error: Video file 'IntroVideo.MP4' not found in bundle.")
            self.player = AVPlayer()
        }
    }
    
    var body: some View {
        ZStack {
            CustomVideoPlayerViewRepresentable(player: player)
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    player.play()
                    
                    NotificationCenter.default.addObserver(
                        forName: .AVPlayerItemDidPlayToEndTime,
                        object: player.currentItem,
                        queue: .main
                    ) { _ in
                        print("Intro video finished playing.")
                        gameVM.introVideoDidFinishOrSkipped()
                    }
                }
                .onDisappear {
                    player.pause()
                    
                    NotificationCenter.default.removeObserver(
                        self,
                        name: .AVPlayerItemDidPlayToEndTime,
                        object: player.currentItem
                    )
                }
            
            Button(action: {
                print("Intro video skipped.")
                player.pause()
                gameVM.introVideoDidFinishOrSkipped()
            }) {
                Image("close")
                    .foregroundColor(.dark)
                    .font(.title2)
            }
            .offset(x:380, y:-150)
            .buttonStyle(.plain)
        }
        .statusBar(hidden: true)
    }
}

struct CustomVideoPlayerViewRepresentable: UIViewControllerRepresentable {
    var player: AVPlayer
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        controller.videoGravity = .resizeAspectFill
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        if uiViewController.player !== player {
            uiViewController.player = player
        }
    }
}

struct IntroVideoView_Previews: PreviewProvider {
    static var previews: some View {
        IntroVideoView(gameVM: GameViewModel())
    }
}
