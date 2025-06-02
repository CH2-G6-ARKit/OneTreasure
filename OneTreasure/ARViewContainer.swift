//
//  ARViewContainer.swift
//  ARIslandGame
//
//  Created by stephan on 21/05/25.
//
import SwiftUI
import RealityKit
import ARKit

struct ARViewContainer: UIViewRepresentable {
    @Binding var selectedPart: String?
    let gem = Object(name: "gems", question: "2+2", choices: ["3", "4", "6", "8"], answer: 1)
    
//    func printEntities(_ entity: Entity, level: Int = 0) {
//        let indent = String(repeating: "  ", count: level)
//        print("\(indent)Entity: \(entity.name)")
//        for child in entity.children {
//            printEntities(child, level: level + 1)
//        }
//    }
//    
//    func printHierarchy(_ entity: Entity, level: Int = 0) {
//        let indent = String(repeating: "  ", count: level)
//        print("\(indent)- \(entity.name) (\(type(of: entity)))")
//        for child in entity.children {
//            printHierarchy(child, level: level + 1)
//        }
//    }

    func makeCoordinator() -> Coordinator {
        Coordinator(selectedPart: $selectedPart)
    }
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        
        context.coordinator.arView = arView
        arView.session.run(config)
        
        
//        let anchor = AnchorEntity(plane: .horizontal)
//        let island = IslandEntity()
//        let chest = ChestEntity()
//        let bird = BirdEntity()
//        
//        chest.generateCollisionShapes(recursive: true)
//        bird.generateCollisionShapes(recursive: true)
//        
//        context.coordinator.arView = arView
//
//        
//        anchor.addChild(island)
//        island.addChild(chest)
//        island.addChild(bird)
//        
//        AudioManager.attachBirdSound(to: bird)
//        
//        arView.scene.anchors.append(anchor)
//        
//        arView.scene.anchors.forEach{ anchor in
//            anchor.children.forEach{
//                print("Entity \($0.name)")
//            }
//        }
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        arView.addGestureRecognizer(tapGesture)
        
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        let anchor = AnchorEntity(plane: .horizontal)
        
        let island = IslandEntity()
        let chest = ChestEntity()
        let bird = BirdEntity()
        
        chest.generateCollisionShapes(recursive: true)
        bird.generateCollisionShapes(recursive: true)
        
        anchor.addChild(island)
        island.addChild(chest)
        island.addChild(bird)
        
        AudioManager.attachBirdSound(to: bird)
        
//        uiView.scene.anchors.append(anchor)
        uiView.scene.addAnchor(anchor)
        
//        uiView.scene.anchors.forEach { anchor in
//            printEntities(anchor)
//        }
    }
    
    class Coordinator: NSObject {
        weak var arView: ARView?
        @Binding var selectedPart: String?

        init(selectedPart: Binding<String?>) {
            _selectedPart = selectedPart
        }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let arView = arView else { return }
            let location = gesture.location(in: arView)

            if let entity = arView.entity(at: location) {
                var current = entity
                while current.parent != nil && current.name == "scene" {
                    current = current.parent!
                }
                print("Tapped entity: \(current.name)")
                selectedPart = current.name
            }
        }
    }
}
