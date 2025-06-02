//
//  Extensions.swift
//  ARIslandGame
//
//  Created by Stephanie Staniswinata on 25/05/25.
//

import SwiftUI

extension Text {
    func outlinedText(strokeColor: Color = .black, textColor: Color = .white, lineWidth: CGFloat = 4) -> some View {
        ZStack {
            // Stroke layers
            ForEach([
                CGSize(width: -lineWidth, height: 0),
                CGSize(width: lineWidth, height: 0),
                CGSize(width: 0, height: -lineWidth),
                CGSize(width: 0, height: lineWidth),
                CGSize(width: -lineWidth, height: -lineWidth),
                CGSize(width: -lineWidth, height: lineWidth),
                CGSize(width: lineWidth, height: -lineWidth),
                CGSize(width: lineWidth, height: lineWidth),
            ], id: \.self) { offset in
                self
                    .foregroundColor(strokeColor) // Stroke color
                    .offset(x: offset.width, y: offset.height+2)
            }

            // Main centered text
            self
                .foregroundColor(textColor)
        }
    }
}

struct ShadowedRoundedBackground: View {
    var cornerRadius: CGFloat = 10
    var color: Color = .dark
    var strokeColor: Color = .dark
    var strokeWidth: CGFloat = 4
    var width: CGFloat = 400
    var height: CGFloat = 250
    var yOffset: CGFloat = 6

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .foregroundColor(color)
            .frame(width: width, height: height)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(strokeColor, lineWidth: strokeWidth)
            )
            .offset(y: yOffset)
    }
}


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
