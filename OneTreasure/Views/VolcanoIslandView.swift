//
//  VolcanoIslandView.swift
//  ARIslandGame
//
//  Created by stephan on 28/05/25.
//

import SwiftUI
import RealityKit
import ARKit
import Combine

struct VolcanoIslandView: View {
    @ObservedObject var viewModel: VolcanoIslandViewModel
    @ObservedObject var gameViewModel: GameViewModel
    @State private var showDialog : Bool = true
    @ObservedObject var viewModelD : DialogViewModel
    
    
    
    var body: some View {
        ZStack {
            VolcanoIslandARViewContainer(viewModel: viewModel)
                .edgesIgnoringSafeArea(.all)

//                .sheet(isPresented: $showDialog) {
//                    DialogView(viewModel: viewModelD)
//                }

            
            //use overlay
            if showDialog {
                //             Semi-transparent background
//                Color.black.opacity(0.4)
//                    .blur(radius: 20)
//                    .edgesIgnoringSafeArea(.all)
//                    .onTapGesture {
//                        withAnimation {
//                            showDialog = false
//                        }
//                    }
                
                // Dialog view
                DialogView(viewModel: viewModelD, showDialog:$showDialog)
                    .padding()
                    .cornerRadius(12)
                    .shadow(radius: 10)
                    .transition(.scale)
                    .zIndex(1)
            }
            
            
            VStack {
                HStack {
                    Image(viewModel.islandData.islandIcon)
                        .resizable()
                        .frame(width: 40, height: 40)
                    
                    Text(viewModel.navigationTitle)
                        .font(.londrinaBlackBody)
                        .fontWeight(.bold)
                        .foregroundColor(.accent)
                        .padding(.horizontal, 9)
                    
                    Spacer()
                    
                    Button {
                        gameViewModel.exitIsland(arView: ARView())
                    } label: {
                        Image("pause")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.dark)
                            .font(.title2)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 24)
                
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
                        Text("Volcano Main treasure already claimed!")
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
                
                Color.black.opacity(0.75)
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
                    .zIndex(1)
                
                RiddleView(viewModel: riddleViewModel,  onClose: {
                    viewModel.dismissRiddle()
                })
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(2)
            }
        }
        .animation(.default, value: viewModel.riddleViewModel == nil)
        .statusBar(hidden: true)
    }
    
    struct VolcanoIslandARViewContainer: UIViewRepresentable {
        @ObservedObject var viewModel: VolcanoIslandViewModel
        
        
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
            var viewModel: VolcanoIslandViewModel
            weak var arView: ARView?
            var cancellables = Set<AnyCancellable>()
            
            var rootSceneAnchor: AnchorEntity?
            var islandEntity: ModelEntity?
            var chestEntity: ModelEntity?
            var birdEntity: ModelEntity?
            
            init(viewModel: VolcanoIslandViewModel) {
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
                        
                        loadedIslandEntity.name = islandData.islandThemeModelName
                        loadedIslandEntity.scale = islandData.islandThemeScale

                        parentAnchor.addChild(loadedIslandEntity)
                        self.islandEntity = loadedIslandEntity
                        print("Coordinator: Island theme '\(islandData.islandThemeModelName)' loaded.")
                        print("Island transform: \(loadedIslandEntity.transform)")

                        
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
                        
                        loadedChestEntity.name = islandData.chestModelFileName
                        loadedChestEntity.scale = islandData.chestScale
                        loadedChestEntity.transform.rotation = simd_quatf(angle: 0, axis: [0, 1, 0])

                        loadedChestEntity.generateCollisionShapes(recursive: true)
                        
                        parentEntity.addChild(loadedChestEntity)
                        self.chestEntity = loadedChestEntity
                        print("Coordinator: Chest '\(islandData.chestModelFileName)' loaded.")
                        print("Chest transform: \(loadedChestEntity.transform)")

                        
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
                        
                        loadedBirdEntity.name = islandData.birdModelFileName
                        loadedBirdEntity.position = islandData.birdPosition
                        loadedBirdEntity.scale = islandData.birdScale
//                        loadedBirdEntity.transform.scale = SIMD3<Float>(1.0, 1.0, 1.0)

                        
                        parentEntity.addChild(loadedBirdEntity)
                        self.birdEntity = loadedBirdEntity
                        print("Coordinator: Bird '\(islandData.birdModelFileName)' loaded.")
                        print("Bird transform: \(loadedBirdEntity.transform)")

                        
                        
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
                    if entity.name == chestEntity?.name || entity.parent?.name == chestEntity?.name {
                        viewModel.interactWithChest()
                    }
                }
            }
        }
    }
}
