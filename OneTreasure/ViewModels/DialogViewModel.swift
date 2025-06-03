//
//  dialogPage.swift
//  OneTreasure
//
//  Created by Ardelia on 02/06/25.
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
    dialogPage(title:"\"Welcome to the first Island!\"", description: "In each island, you will need to find an object to open the riddle. the only guide you have is the sound faint, distant, but growing stronger as you approach"),
    dialogPage(title:"YOUR TASK", description: "1. Follow the sound: The island is alive with echoes-some are clues, others are distractions. The closer you get to the hidden object, the louder and clearer the sound becomes"),
    dialogPage(title:"YOUR TASK", description: "2. Solve the riddle: Each object you find will reveal a piece of the story and lead you to the next challenge. Pay attention to your surroundings; the answer might be hidden in plain sight"),
    dialogPage(title:"YOUR TASK", description: "3. Uncover the mystery: Once you answer the riddle, you will get a fragment of map that leads yo to get back the lost ship"),
    
]
