//
//  ButtonView.swift
//  ARIslandGame
//
//  Created by Stephanie Staniswinata on 27/05/25.
//

import SwiftUI

struct ButtonView: View {
    let btnType: BtnTypes
    
    
    enum BtnTypes{
        case text(String)
        case icon(String)
        case both(String, String)
    }
    var body: some View {
        ZStack{
            switch btnType {
            case .text(let string):
                ShadowedRoundedBackground(width: 150, height: 50)
                Text(string)
                    .font(.londrinaTitle)
                    .frame(width: 150, height: 50)
                    .foregroundColor(.accent)
                    .background(.dark2)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.dark2, lineWidth: 4)
                    )
            case .icon(let image):
                ShadowedRoundedBackground(cornerRadius: 30,strokeWidth: 3 , width: 45, height: 45, yOffset: 4)
                Image(image)
                    .renderingMode(.template)
                    .scaleImage(ratio: 1.5, imageName: image)
                    .background(.accent)
                    .clipShape(Circle())
                    .foregroundColor(.dark)
                    .cornerRadius(10)
                    .overlay(
                        Circle()
                            .stroke(.dark, lineWidth: 2)
                    )
            case .both(let string, let img):
                ShadowedRoundedBackground(width: 150, height: 50)
                HStack{
                    Text(string)
                        .font(.londrinaTitle)
                        .foregroundColor(.accent)
                    Image(img)
                        .renderingMode(.template)
                        .scaleImage(ratio: 0.1, imageName: "compas")
                        .foregroundColor(.accent)
                }
                .frame(width: 150, height: 50)
                .background(.dark2)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.dark2, lineWidth: 4)
                )
            }
        }
    }
}

#Preview {
//    ButtonView(btnType: .text("text"))
    ButtonView(btnType: .icon("leftArrow"))
//    ButtonView(btnType: .both("text", "compas"))
}
