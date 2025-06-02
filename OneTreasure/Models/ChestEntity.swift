//
//  ChestEntity.swift
//  ARIslandGame
//
//  Created by stephan on 20/05/25.
//

import RealityKit

final class ChestEntity: Entity, HasModel {
    override required init() {
        super.init()
        let model = try! Entity.loadModel(named: "chest")
        self.name = "gems"
        model.generateCollisionShapes(recursive: true)
        model.components[CollisionComponent.self]?.mode = .default
        model.scale = .init(repeating: 0.00002)
        model.position = [0.016, 0.288, -0.00658]
        self.addChild(model)
    }
}
