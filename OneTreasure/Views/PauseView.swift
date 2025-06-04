//
//  PauseView.swift
//  OneTreasure
//
//  Created by stephan on 04/06/25.
//

import SwiftUI
import RealityKit

struct PauseView: View {
    var onResume: () -> Void
    var onExit: () -> Void

    var body: some View {
        ZStack{
            Color.black.opacity(0.75)
                .edgesIgnoringSafeArea(.all)
                .transition(.opacity)
                .zIndex(0)
            
            ShadowedRoundedBackground(width: 361, height: 92)
            VStack {
                VStack(spacing: 16) {
                    HStack {
                        Button(action: onExit) {
                            ZStack {
                                ShadowedRoundedBackground(width: 96, height: 48)
                                Text("GO TO MAP")
                                    .font(.londrinaHeadline)
                                    .foregroundColor(.dark)
                                    .frame(width: 96, height: 48)
                                    .background(.accent)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(.dark, lineWidth: 4)
                                    )
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        
                        Spacer()
                            .frame(maxWidth: 0, minHeight: 0)
                            .padding(16)
                        
                        Button(action: onResume) {
                            ZStack {
                                ShadowedRoundedBackground(width: 96, height: 48)
                                Text("CONTINUE")
                                    .font(.londrinaHeadline)
                                    .foregroundColor(.accent)
                                    .frame(width: 96, height: 48)
                                    .background(.dark)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(.dark, lineWidth: 4)
                                    )
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                    }
                    
                }
                .frame(width: 361, height: 92)
            }
            .background(Color.accent)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.dark, lineWidth: 4)
            )
            .transition(.scale.combined(with: .opacity))
            
            Text("GAME PAUSED")
                .foregroundColor(.dark)
                .font(.londrinaHeadline)
                .frame(width: 131, height: 48)
                .background(.accent)
                .cornerRadius(50)
                .overlay(
                    RoundedRectangle(cornerRadius: 50)
                        .stroke(.brown, lineWidth: 2)
                )
                .offset(y: -(210/3.6))
        }
    }
}

struct PauseView_Previews: PreviewProvider {
    static var previews: some View {
        PauseView(onResume: {print("Resume tapped.")},
                  onExit: {print("Exit tapped.")})
    }
}
