//
//  FragmentView.swift
//  ARIslandGame
//
//  Created by Stephanie Staniswinata on 26/05/25.
//

import SwiftUI

struct FragmentView: View {
    var count: Int
    var fragments : [FragmentModel] = [
        FragmentModel(name: "frag1", ratio: 0.2, xOffset: -116*0.4, yOffset: -93*0.4),
        FragmentModel(name: "frag2", ratio: 0.2, xOffset: 119*0.4, yOffset: -92.2*0.4),
        FragmentModel(name: "frag3", ratio: 0.2, xOffset: -114.8*0.4, yOffset: 93*0.4),
        FragmentModel(name: "frag4", ratio: 0.2, xOffset: 115.3*0.4, yOffset: 93*0.4)
    ]

    var body: some View {
        ZStack{
            Image("base")
                .scaleImage(ratio: 0.2, imageName: "base")
            ForEach(0..<count, id: \.self){ i in
                Image(fragments[i].name)
                    .scaleImage(ratio: fragments[i].ratio, imageName: fragments[i].name)
                    .offset(x:fragments[i].xOffset, y:fragments[i].yOffset)
            }
        }
    }
}

#Preview {
    FragmentView(count: 4)
}
