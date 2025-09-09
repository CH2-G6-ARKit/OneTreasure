//
//  PopUpView.swift
//  onetreasure
//
//  Created by Stephanie Staniswinata on 19/05/25.
//
import SwiftUI

struct PopUpView: View {
    @Binding var showPopUp: Bool
    let type: Types
    var onAnswered: ((Bool) -> Void)? = nil
    var onRetry: (() -> Void)? = nil
    
    enum Types {
        case right
        case fragment(Int, Bool)
        case lost
        case wrong(Int)
        case win
    }
    
    var body: some View {
        if showPopUp {
            ZStack {
                Color.black.opacity(0.3).ignoresSafeArea()
                
                switch type {
                case .right:
                    ZStack{
                        Image("right")
                            .scaleImage(ratio: 0.7, imageName: "right")
                        VStack{
                            Text("RIDDLE")
                                .font(.londrinaBig)
                                .outlinedText(strokeColor: .dark, textColor: .accent, lineWidth: 5)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                                .padding()
                                .offset(y:75)
                            Text("SOLVED")
                                .font(.londrinaBig)
                                .outlinedText(strokeColor: .dark, textColor: .accent, lineWidth: 5)
                                .multilineTextAlignment(.center)
                                .padding()
                        }
                        .offset(y:50)
                    }
                    .offset(y:-30)
                    
                    
                case .fragment(let count, let showBtn):
                    ZStack {
                        ShadowedRoundedBackground()
                        VStack{
                            FragmentView(count: count)
                            if showBtn
                            {
                                Button {
//                                    print("close pop up")
                                    showPopUp = false
                                } label: {
                                    ButtonView(btnType: .text("OK"))
                                    }
                            }
                        }
                        .frame(width: 400, height: 250)
                        .background(.accent)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.dark, lineWidth: 4)
                        )
                        .padding(.horizontal, 100)
                        
                        Text("YOU GOT NEW FRAGMENT!")
                            .font(.londrinaHeadline)
                            .foregroundColor(.dark)
                            .frame(width: 220, height: 40)
                            .background(.accent)
                            .cornerRadius(40)
                            .overlay(
                                RoundedRectangle(cornerRadius: 40)
                                    .stroke(.dark, lineWidth: 4)
                            )
                            .offset(y: -(500/4))
                    }
                    
                case .lost:
                    ZStack{
                        Image("lost")
                            .scaleImage(ratio: 0.7, imageName: "right")
                        Text("YOU LOST")
                            .font(.londrinaBig)
                            .outlinedText(strokeColor: .dark, textColor: .accent, lineWidth: 5)
                            .multilineTextAlignment(.center)
                            .padding()
                            .offset(y:60)
                    }
                    
                case .wrong(let chance):
                    VStack{
                        ZStack{
                            Image("wrong")
                                .scaleImage(ratio: 0.7, imageName: "wrong")
                            VStack{
                                Text("WRONG")
                                    .font(.londrinaBig)
                                    .outlinedText(strokeColor: .dark, textColor: .accent, lineWidth: 5)
                                    .fontWeight(.bold)
                                    .multilineTextAlignment(.center)
                                    .padding()
                                    .offset(y:70)
                                Text("ANSWER")
                                    .font(.londrinaBig)
                                    .outlinedText(strokeColor: .dark, textColor: .accent, lineWidth: 5)
                                    .multilineTextAlignment(.center)
                                    .padding()
                            }
                            .offset(y:50)
                        }
                        .offset(y:-30)
                        ZStack{
                            ShadowedRoundedBackground(width: 150, height: 40)
                            //                                .frame(width: 150, height: 40)
                            Text("\(chance) \(chance<=1 ?"chance" : "chances" ) left")
                                .font(.londrinaBody)
                                .frame(width: 150, height: 40)
                                .foregroundColor(.dark)
                                .background(.accent)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(.dark, lineWidth: 4)
                                )
                        }
                    }
                    
                case .win:
                    ZStack {
                        ShadowedRoundedBackground()
                        VStack{
                            ZStack(alignment:.bottom){
                                Image("Ship")
                                    .scaleImage(ratio: 0.18, imageName: "Ship")
                                    .zIndex(1)
                                Image("Sea")
                                    .scaleImage(ratio: 0.4, imageName: "Sea")
                            }
                        }
                        .frame(width: 400, height: 250)
                        .background(.accent)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.dark, lineWidth: 4)
                        )
                        
                        Text("VICTORY!")
                            .font(.londrinaHeadline)
                            .foregroundColor(.dark)
                            .frame(width: 220, height: 40)
                            .background(.accent)
                            .cornerRadius(40)
                            .overlay(
                                RoundedRectangle(cornerRadius: 40)
                                    .stroke(.dark, lineWidth: 4)
                            )
                            .offset(y: -(500/4))
                    }
                }
            }
        }
    }
}

#Preview {
    //            PopUpView(showPopUp: true, type: .right)
    //        PopUpView(showPopUp: true, type: .wrong(2))
//    PopUpView(showPopUp: .constant(true), type: .fragment(2, true))
//    PopUpView(showPopUp: .constant(true), type: .fragment(2, false))
    //    PopUpView(showPopUp: true, type: .lost)
        PopUpView(showPopUp: .constant(true), type: .win)
}
