//
//  FragmentModel.swift
//  ARIslandGame
//
//  Created by Stephanie Staniswinata on 27/05/25.
//
import Foundation
import SwiftData

@Model
final class FragmentModel{
    var name: String
    var ratio: Double
    var xOffset : Double
    var yOffset : Double
    
    init(name: String, ratio: Double, xOffset: Double, yOffset: Double) {
        self.name = name
        self.ratio = ratio
        self.xOffset = xOffset
        self.yOffset = yOffset
    }
}

