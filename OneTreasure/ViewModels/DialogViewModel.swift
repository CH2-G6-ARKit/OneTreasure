//
//  DialogViewModel.swift
//  OneTreasure
//
//  Created by Ardelia on 03/06/25.
//


//
//  DialogViewModel.swift
//  ARIslandGame
//
//  Created by Ardelia on 22/05/25.
//

import Foundation
import SwiftUI
import Combine

class DialogViewModel: ObservableObject{
    @Published var currentIndex : Int = 0
    
    let dialogPages : [dialogPage]
    
    init() {
        self.dialogPages = dialogPagesData
    }
    
    
    
    func nextPage(){
        if currentIndex < dialogPages.count - 1 {
            currentIndex += 1
        }
    }
    
    func isMiddlePage() -> Bool {
        return currentIndex > 0 && currentIndex < dialogPages.count - 1
    }
    
    func isLastPage() -> Bool {
        return currentIndex == dialogPages.count - 1
    }
    
    func prevPage(){
        if currentIndex > 0 {
            currentIndex -= 1
        }
    }
    
    func isfirstPage() -> Bool {
        return currentIndex == 0
    }
    
    
}

let dialogPagesData = [
    dialogPage(title:"\"Welcome to the first Island!\"", description: "In each island, you will need to find an object to open the riddle. The only guide you have is the sound: faint, distant, but growing stronger as you approach."),
    dialogPage(title:"YOUR TASK", description: "1. Follow the sound: The island is alive with echoes. The closer you get to the hidden object, the louder and clearer the sound becomes."),
    dialogPage(title:"YOUR TASK", description: "2. Solve the riddle: Each riddle you encounter will test your wit—it could be a simple question, a clever guess, or a pattern waiting to be uncovered."),
    dialogPage(title:"YOUR TASK", description: "3. Your reward? A fragment of the truth. Piece these fragments together, and they will guide you toward what you seek most: your lost ship."),
    dialogPage(title:"", description: "Let’s find the object and solve the riddle!"),
    
]
