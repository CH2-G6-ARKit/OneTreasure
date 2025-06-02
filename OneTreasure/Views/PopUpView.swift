//
//  PopUpView.swift
//  onetreasure
//
//  Created by Stephanie Staniswinata on 19/05/25.
//
import SwiftUI

struct ChoiceButton: View {
    let choice: String
    let item: MultipleChoiceQuestionItem
    let action: (String) -> Void
    
    var body: some View {
        Button {
            action(choice)
        } label: {
            ZStack {
                ShadowedRoundedBackground(strokeWidth: 2, width:150, height:50, yOffset: 4)
                Text(choice)
                    .font(.londrinaBody)
                    .frame(width: 150, height: 50)
                    .foregroundColor(.dark)
                    .background(.accent)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.dark, lineWidth: 2)
                    )
            }
        }
    }
}


struct PopUpView: View {
    @Binding var showPopUp: Bool
    let type: Types
    var onAnswered: ((Bool) -> Void)? = nil
    var onRetry: (() -> Void)? = nil

    
    func buttonAction(num: String, item: MultipleChoiceQuestionItem) {
//            let isCorrect = num == item.choices[item.answer]
        let isCorrect = num == item.correctAnswerOptionsId
            onAnswered?(isCorrect)
        }
    
    enum Types {
//        case question(MultipleChoiceQuestionItem)
        case result(Bool)
        case fragment
        case lost
    }
    
    var body: some View {
        if showPopUp {
            ZStack {
                Color.black.opacity(0.3).ignoresSafeArea()
                
                switch type {
                case .result(let isCorrect):
                    ZStack{
                        Image(isCorrect ? "right" : "wrong")
                            .scaleImage(ratio: 0.7, imageName: "right")
                        Text(isCorrect ? "RIDDLE" : "WRONG")
                            .font(.jaroBig)
                            .outlinedText(strokeColor: .dark, textColor: .accent, lineWidth: 5.5)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
//                            .bold()
                            .padding()
                            .offset(y:60)
                        Text(isCorrect ? "SOLVED!" : "ANSWER")
                            .font(.jaroBig)
                            .outlinedText(strokeColor: .dark, textColor: .accent, lineWidth: 5.5)
                            .multilineTextAlignment(.center)
                            .padding()
                            .offset(y:110)
                    }
                    .offset(y:-30)
                    if !isCorrect {
                        ZStack {
                            ShadowedRoundedBackground(strokeWidth: 2, width: 150, height: 50, yOffset: 4)
                            Button {
                                onRetry?()
                            } label: {
                                Text("RETRY")
                                    .font(.londrinaTitle)
                                    .frame(width: 150, height: 50)
                                    .foregroundColor(.accent)
                                    .background(.dark2)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(.dark2, lineWidth: 2)
                                    )
                            }
                        }
                        .offset(y: 150)
                    }

                    
                case .fragment:
                    ZStack {
                        ShadowedRoundedBackground()
                        VStack {
                            Image("map")
                                .resizable()
                                .frame(width:200, height:150)
//                            NavigationLink(destination: MapView()
//                                .ignoresSafeArea(edges: .all)
//                            ) {
//                                Text("OK")
//                                    .padding()
//                                    .padding(.horizontal, 20)
//                                    .foregroundColor(.white)
//                                    .background(.black)
//                                    .cornerRadius(10)
//                            }
                        }
                        .frame(width: 400, height: 250)
                        .background(.accent)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.dark, lineWidth: 4)
                        )
                        .padding(.horizontal, 100)
                        .transition(.scale.combined(with: .opacity))
                                                
                        Text("YOU GOT NEW FRAGMENT!")
                            .font(.londrinaHeadline)
                            .foregroundColor(.accent)
                            .frame(width: 200, height: 50)
                            .background(.dark)
                            .cornerRadius(10)
                            .offset(y: -(500/4))
                        
                    }
                    
                case .lost:
                    ZStack{
                        Image("lost")
                            .scaleImage(ratio: 0.7, imageName: "right")
                        Text("YOU LOST")
                            .font(.jaroBig)
                            .outlinedText(strokeColor: .dark, textColor: .accent, lineWidth: 6)
                            .multilineTextAlignment(.center)
                            .padding()
                            .offset(y:60)
                    }
                }
            }
        }
    }
}


#Preview {
//            PopUpView(showPopUp: .constant(true), type: .result(true))
//        PopUpView(showPopUp: .constant(true), type: .result(false))
        PopUpView(showPopUp: .constant(true), type: .fragment)
//    PopUpView(showPopUp: .constant(true), type: .lost)
}
