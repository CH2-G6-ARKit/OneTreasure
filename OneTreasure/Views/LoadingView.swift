//
//  LoadingView.swift
//  OneTreasure
//
//  Created by Stephanie Staniswinata on 04/06/25.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                .scaleEffect(2.0, anchor: .center)
            Text("Loading Ancient Maps...")
                .font(.title3)
                .padding(.top)
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    LoadingView()
}
