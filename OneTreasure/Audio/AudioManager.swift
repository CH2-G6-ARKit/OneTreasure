//
//  AudioManager.swift
//  ARIslandGame
//
//  Created by stephan on 20/05/25.
//

import RealityKit

enum AudioManager {
    static func attachBirdSound(to entity: Entity) {
        entity.spatialAudio = SpatialAudioComponent(gain: -5)
        do {
            let resource = try AudioFileResource.load(named: "an_ominous-crow-call-255173.mp3", configuration: .init(
                loadingStrategy: .preload,
                shouldLoop: true,
                shouldRandomizeStartTime: true
            ))
            entity.playAudio(resource)
        } catch {
            print("Error loading audio file: \(error.localizedDescription)")
        }
    }
    
}
