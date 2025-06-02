//
//  DummyIslandView.swift
//  ARIslandGame
//
//  Created by stephan on 28/05/25.
//

import SwiftUI
import RealityKit
import ARKit
import Combine

struct DummyIslandView: View {
    @ObservedObject var viewModel: DummyIslandViewModel
    @ObservedObject var gameViewModel: GameViewModel
    
    var body: some View {
        ZStack {
            DummyIslandARViewContainer(viewModel: viewModel)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Text(viewModel.navigationTitle)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(10)
                    
                    Spacer()
                    
                    Button {
                        gameViewModel.exitIsland(arView: ARView())
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.red.opacity(0.7))
                            .clipShape(Circle())
                            .shadow(radius: 3)
                    }
                }
                .padding(.horizontal)
                .padding(.top, (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.safeAreaInsets.top ?? 0)
                
                Spacer()
                
                VStack(spacing: 15) {
                    Text(viewModel.guidanceFeedback)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(8)
                        .multilineTextAlignment(.center)
                    
                    if viewModel.currentExperienceState == .completedSuccessfully {
                        Text("Island Objective Complete!")
                            .font(.title2).fontWeight(.bold)
                            .foregroundColor(.green)
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .shadow(radius: 3)
                    } else if viewModel.currentExperienceState == .alreadyCompleted {
                        Text("Main treasure already claimed!")
                            .font(.subheadline).fontWeight(.medium)
                            .foregroundColor(.yellow)
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .shadow(radius: 3)
                    } else if viewModel.currentExperienceState == .failed {
                        Text("Try this island again later...")
                            .font(.title3).fontWeight(.medium)
                            .foregroundColor(.orange)
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .shadow(radius: 3)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.safeAreaInsets.bottom ?? 0 + 20)
            }
            .animation(.easeInOut, value: viewModel.guidanceFeedback)
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: viewModel.isChestVisibleAndInteractive)
            
            if let riddleViewModel = viewModel.riddleViewModel {
                RiddleView(viewModel: riddleViewModel)
                    .padding(20)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 25, style: .continuous))
                    .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                    .padding(30)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.45).edgesIgnoringSafeArea(.all))
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(1)
            }
        }
        .animation(.default, value: viewModel.riddleViewModel == nil)
        .statusBar(hidden: true)
    }
    
    struct DummyIslandARViewContainer: UIViewRepresentable {
        @ObservedObject var viewModel: DummyIslandViewModel
        
        func makeUIView(context: Context) -> ARView {
            let arView = ARView(frame: .zero, cameraMode: .ar, automaticallyConfigureSession: false)
            
            let config = ARWorldTrackingConfiguration()
            config.planeDetection = [.horizontal]
            config.environmentTexturing = .automatic
            if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
                config.sceneReconstruction = .mesh
            }
            arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
            
            arView.session.delegate = context.coordinator
            context.coordinator.arView = arView
            
            context.coordinator.setupSceneRootAnchor()
            
            viewModel.startExperience(arView: arView)
            
            let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
            arView.addGestureRecognizer(tapGesture)
            
            return arView
        }
        
        func updateUIView(_ uiView: ARView, context: Context) {
        }
        
        func makeCoordinator() -> Coordinator {
            Coordinator(viewModel: viewModel)
        }
        
        @MainActor
        class Coordinator: NSObject, ARSessionDelegate {
            var viewModel: DummyIslandViewModel
            weak var arView: ARView?
            var cancellables = Set<AnyCancellable>()
            
            var rootSceneAnchor: AnchorEntity?
            var islandEntity: ModelEntity?
            var chestEntity: ModelEntity?
            var birdEntity: ModelEntity?
            
            init(viewModel: DummyIslandViewModel) {
                self.viewModel = viewModel
                super.init()
            }
            
            func setupSceneRootAnchor() {
                guard let arView = arView else {
                    print("Coordinator: ARView not available for scene setup.")
                    return
                }
                
                let anchor = AnchorEntity(plane: .horizontal)
                anchor.name = "worldRootAnchor"
                anchor.position = [0, 0, -0.5]
                arView.scene.addAnchor(anchor)
                self.rootSceneAnchor = anchor
                print("Coordinator: Root scene anchor created.")
                
                loadIslandThemeAsset(parentAnchor: anchor)
            }
            
            private func loadIslandThemeAsset(parentAnchor: AnchorEntity) {
                let islandData = viewModel.islandData
                Entity.loadModelAsync(named: islandData.islandThemeModelName)
                    .receive(on: DispatchQueue.main)
                    .sink(receiveCompletion: { [weak self] completion in
                        if case .failure(let error) = completion {
                            print("Coordinator Error: Failed to load island theme model '\(islandData.islandThemeModelName)': \(error)")
                            self?.viewModel.guidanceFeedback = "Error: Could not load island visuals."
                        }
                    }, receiveValue: { [weak self] loadedIslandEntity in
                        guard let self = self else { return }
                        
                        loadedIslandEntity.name = "edited_island"
                        loadedIslandEntity.position = islandData.islandThemePosition
                        loadedIslandEntity.scale = islandData.islandThemeScale
                        
                        parentAnchor.addChild(loadedIslandEntity)
                        self.islandEntity = loadedIslandEntity
                        print("Coordinator: Island theme '\(islandData.islandThemeModelName)' loaded.")
                        
                        self.loadChestAsset(parentEntity: loadedIslandEntity)
                        self.loadBirdAsset(parentEntity: loadedIslandEntity)
                    })
                    .store(in: &cancellables)
            }
            
            private func loadChestAsset(parentEntity: Entity) {
                let islandData = viewModel.islandData
                Entity.loadModelAsync(named: islandData.chestModelFileName)
                    .receive(on: DispatchQueue.main)
                    .sink(receiveCompletion: { [weak self] completion in
                        if case .failure(let error) = completion {
                            print("Coordinator Error: Failed to load chest model '\(islandData.chestModelFileName)': \(error)")
                            self?.viewModel.guidanceFeedback = "Error: Essential island element missing."
                        }
                    }, receiveValue: { [weak self] loadedChestEntity in
                        guard let self = self else { return }
                        
                        loadedChestEntity.name = "chest"
                        loadedChestEntity.position = islandData.chestPosition
                        loadedChestEntity.scale = islandData.chestScale
                        loadedChestEntity.generateCollisionShapes(recursive: true)
                        
                        parentEntity.addChild(loadedChestEntity)
                        self.chestEntity = loadedChestEntity
                        print("Coordinator: Chest '\(islandData.chestModelFileName)' loaded.")
                        
                        let chestWorldTransform = loadedChestEntity.transformMatrix(relativeTo: nil)
                        let chestWorldPosition = SIMD3<Float>(chestWorldTransform.columns.3.x, chestWorldTransform.columns.3.y, chestWorldTransform.columns.3.z)
                        self.viewModel.setChestWorldTarget(position: chestWorldPosition)
                    })
                    .store(in: &cancellables)
            }
            
            private func loadBirdAsset(parentEntity: Entity) {
                let islandData = viewModel.islandData
                Entity.loadModelAsync(named: islandData.birdModelFileName)
                    .receive(on: DispatchQueue.main)
                    .sink(receiveCompletion: { [weak self] completion in
                        if case .failure(let error) = completion {
                            print("Coordinator Error: Failed to load bird model '\(islandData.birdModelFileName)': \(error)")
                        }
                    }, receiveValue: { [weak self] loadedBirdEntity in
                        guard let self = self else { return }
                        
                        loadedBirdEntity.name = "crow"
                        loadedBirdEntity.position = islandData.birdPosition
                        loadedBirdEntity.scale = islandData.birdScale
                        
                        parentEntity.addChild(loadedBirdEntity)
                        self.birdEntity = loadedBirdEntity
                        print("Coordinator: Bird '\(islandData.birdModelFileName)' loaded.")
                        
                        
                        do {
                            try AudioManagers.attachSpatialAudio(
                                named: islandData.birdAudioFileName,
                                to: loadedBirdEntity,
                                shouldLoop: true,
                                randomizeStartTime: false,
                                gain: -3
                            )
                            print("Coordinator: Guiding bird sound '\(islandData.birdAudioFileName)' attached to bird.")
                        } catch { print("Coordinator Error: Failed to attach audio to bird: \(error)") }
                        
                        
                        if let animation = loadedBirdEntity.availableAnimations.first {
                            loadedBirdEntity.playAnimation(animation.repeat())
                        }
                    })
                    .store(in: &cancellables)
            }
            
            func session(_ session: ARSession, didUpdate frame: ARFrame) {
                let cameraTransform = frame.camera.transform
                let playerPosition = SIMD3<Float>(cameraTransform.columns.3.x, cameraTransform.columns.3.y, cameraTransform.columns.3.z)
                viewModel.updatePlayerPosition(playerPosition)
            }
            
            @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
                guard let arView = arView else { return }
                guard viewModel.currentExperienceState == .chestFound && viewModel.isChestVisibleAndInteractive else {
                    return
                }
                
                let location = recognizer.location(in: arView)
                if let entity = arView.entity(at: location) {
                    if entity.name == "chest" || entity.parent?.name == "chest" {
                        viewModel.interactWithChest()
                    }
                }
            }
        }
    }
}

//#Preview {
//    DummyIslandView()
//}
