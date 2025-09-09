//
//  dump.swift
//  onetreasure
//
//  Created by Stephanie Staniswinata on 13/05/25.
//


//struct ARViewContainer : UIViewRepresentable {
//    //    store the 3d model name -> displayed in ARView
//    @Binding var modelName: String
//
//    //    makeUIView - create the view object and init state
//    func makeUIView(context: Context) -> ARView {
//        // create arview object > display the 3d model
//        let arView = ARView(frame: .zero)
//
//        // how to track the real world
//        let config = ARWorldTrackingConfiguration()
//        // detect flat surface
//        config.planeDetection = [.horizontal]
//        // give realistic image-based lighting for the model
//        config.environmentTexturing = .automatic
//
//        // set the arview with the config (plane and env texture)
//        arView.session.run(config)
//        return arView
//    }
//
//    //    update the state of view
//    func updateUIView(_ uiView: ARView, context: Context) {
//        // to detect any plane, tell reality kit where to pin the model to real world
//        let anchorEntity = AnchorEntity(plane: .any)
//
//        // load the model from modelName
//        guard let modelEntity = try? Entity.loadModel(named: modelName) else { return }
//        modelEntity.scale = .init(repeating:0.2)
//
//        // loaded model as a child to anchorEntity
//        anchorEntity.addChild(modelEntity)
//
//        // set the anchor to the scene > to display the model
//        uiView.scene.addAnchor(anchorEntity)
//    }
//
//}
