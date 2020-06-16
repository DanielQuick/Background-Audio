/*
	Copyright (C) 2016 Apple Inc. All Rights Reserved.
	See LICENSE.txt for this sample’s licensing information
	
	Abstract:
	`RemoteCommandManager` contains all the APIs calls to MPRemoteCommandCenter to enable and disable various remote control events.
 */

import Foundation
import MediaPlayer

class RemoteCommandManager: NSObject {
    
    // MARK: Properties
    
    /// Reference of `MPRemoteCommandCenter` used to configure and setup remote control events in the application.
    fileprivate let remoteCommandCenter = MPRemoteCommandCenter.shared()
    
    /// The instance of `AssetPlaybackManager` to use for responding to remote command events.
    let assetPlaybackManager: AssetPlaybackManager
    
    // MARK: Initialization.
    
    init(assetPlaybackManager: AssetPlaybackManager) {
        self.assetPlaybackManager = assetPlaybackManager
    }
    
    deinit {
        activatePlaybackCommands(false)
    }
    
    // MARK: MPRemoteCommand Activation/Deactivation Methods

    func activatePlaybackCommands(_ enable: Bool) {
        if enable {
            remoteCommandCenter.playCommand.addTarget(self, action: #selector(RemoteCommandManager.handlePlayCommandEvent(_:)))
            remoteCommandCenter.pauseCommand.addTarget(self, action: #selector(RemoteCommandManager.handlePauseCommandEvent(_:)))
            remoteCommandCenter.stopCommand.addTarget(self, action: #selector(RemoteCommandManager.handleStopCommandEvent(_:)))
            remoteCommandCenter.togglePlayPauseCommand.addTarget(self, action: #selector(RemoteCommandManager.handleTogglePlayPauseCommandEvent(_:)))
            
        }
        else {
            remoteCommandCenter.playCommand.removeTarget(self, action: #selector(RemoteCommandManager.handlePlayCommandEvent(_:)))
            remoteCommandCenter.pauseCommand.removeTarget(self, action: #selector(RemoteCommandManager.handlePauseCommandEvent(_:)))
            remoteCommandCenter.stopCommand.removeTarget(self, action: #selector(RemoteCommandManager.handleStopCommandEvent(_:)))
            remoteCommandCenter.togglePlayPauseCommand.removeTarget(self, action: #selector(RemoteCommandManager.handleTogglePlayPauseCommandEvent(_:)))
        }
        
        remoteCommandCenter.playCommand.isEnabled = enable
        remoteCommandCenter.pauseCommand.isEnabled = enable
        remoteCommandCenter.stopCommand.isEnabled = enable
        remoteCommandCenter.togglePlayPauseCommand.isEnabled = enable
    }
    
    // MARK: MPRemoteCommand handler methods.
    
    // MARK: Playback Command Handlers
    @objc func handlePauseCommandEvent(_ event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        assetPlaybackManager.pause()
        
        return .success
    }
    
    @objc func handlePlayCommandEvent(_ event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        assetPlaybackManager.play()
        
        return .success
    }
    
    @objc func handleStopCommandEvent(_ event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        assetPlaybackManager.stop()
        
        return .success
    }
    
    @objc func handleTogglePlayPauseCommandEvent(_ event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        assetPlaybackManager.togglePlayPause()
        
        return .success
    }
}

// MARK: Convienence Category to make it easier to expose different types of remote command groups as the UITableViewDataSource in RemoteCommandListTableViewController.
extension RemoteCommandManager {
    
    }
