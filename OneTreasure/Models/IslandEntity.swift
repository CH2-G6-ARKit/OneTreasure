//
//  IslandEntity.swift
//  ARIslandGame
//
//  Created by stephan on 20/05/25.
//

import RealityKit

final class IslandEntity: Entity, HasModel {
    override required init() {
        super.init()
        let model = try! Entity.loadModel(named: "edited_island")
        model.components.set(CollisionComponent(shapes: []))
        model.scale = .init(repeating: 0.2)
        model.position = [0, 0, -0.0005]
        
        self.addChild(model)
        self.name = "edited_island"
    }
}
