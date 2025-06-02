//
//  AudioUtils.swift
//  ARIslandGame
//
//  Created by stephan on 28/05/25.
//
import RealityKit
import AVFoundation

enum AudioManagersError: Error {
    case resourceLoadingFailed(soundName: String, underlyingError: Error)
    case componentOrEntityMissing
}

enum AudioManagers {
        
    @discardableResult
    static func attachSpatialAudio(
        named soundFileName: String,
        to entity: Entity,
        shouldLoop: Bool = true,
        randomizeStartTime: Bool = true,
        gain: Double = 0,
        loadingStrategy: AudioFileResource.LoadingStrategy = .preload
    ) throws -> AudioPlaybackController {
        if entity.components[SpatialAudioComponent.self] == nil {
            entity.components.set(SpatialAudioComponent())
        }
        entity.spatialAudio?.gain = gain
        
        do {
            let audioResource = try AudioFileResource.load(
                named: soundFileName, configuration: .init(
                    loadingStrategy: loadingStrategy,
                    shouldLoop: shouldLoop,
                    shouldRandomizeStartTime: randomizeStartTime
                )
            )
            return entity.playAudio(audioResource)
        } catch {
            print("Audio Manager Error: Failed to load or play audio file '\(soundFileName)': \(error.localizedDescription)")
            throw AudioManagersError.resourceLoadingFailed(soundName: soundFileName, underlyingError: error)
        }
    }
    
    static func stopAllSounds(on entity: Entity) {
        entity.stopAllAudio()
    }
}
