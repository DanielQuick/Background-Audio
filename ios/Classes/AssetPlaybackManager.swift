/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    `AssetPlaybackManager` manages the playback of `Asset` objects.  It contains all the necessary KVO logic needed when using AVPlayer as well as exposes playback methods that are used by the `RemoteCommandCenter` class.
 */

import AVFoundation
import MediaPlayer

import UIKit

class AssetPlaybackManager: NSObject {

    var onPause: (() -> ())?
    var onPlay: (() -> ())?
    
    // MARK: Types
    
    /// An enumeration of possible playback states that `AssetPlaybackManager` can be in.
    ///
    /// - initial: The playback state that `AssetPlaybackManager` starts in when nothing is playing.
    /// - playing: The playback state that `AssetPlaybackManager` is in when its `AVPlayer` has a `rate` != 0.
    /// - paused: The playback state that `AssetPlaybackManager` is in when its `AVPlayer` has a `rate` == 0.
    /// - interrupted: The playback state that `AssetPlaybackManager` is in when audio is interrupted.
    enum playbackState {
        case initial, playing, paused, interrupted
    }
    
    /// Notification that is posted when currently playing `Asset` did change.
    static let currentAssetDidChangeNotification = Notification.Name("currentAssetDidChangeNotification")
    
    // MARK: Properties
    
    /// The instance of AVPlayer that will be used for playback of AssetPlaybackManager.playerItem.
    let player = AVPlayer()
    
    /// The state that the internal `AVPlayer` is in.
    var state: AssetPlaybackManager.playbackState = .initial
    
    /// A Bool for tracking if playback should be resumed after an interruption.  See README.md for more information.
    private var shouldResumePlaybackAfterInterruption = true
    
    /// The AVPlayerItem associated with AssetPlaybackManager.asset.urlAsset
    fileprivate var playerItem: AVPlayerItem! {
        willSet {
            if playerItem != nil {
                playerItem.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), context: nil)
            }
        }
        didSet {
            if playerItem != nil {
                playerItem.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.initial, .new], context: nil)
            }
        }
    }
    
    /// The Asset that is currently being loaded for playback.
    var asset: AVAsset! {
        willSet {
            if asset != nil {
                asset.removeObserver(self, forKeyPath: #keyPath(AVURLAsset.isPlayable), context: nil)
            }
        }
        didSet {
            if asset != nil {
                asset.addObserver(self, forKeyPath: #keyPath(AVURLAsset.isPlayable), options: [.initial, .new], context: nil)
            }
            else {
                // Unload currentItem so that the state is updated globally.
                player.replaceCurrentItem(with: nil)
            }
            
            NotificationCenter.default.post(name: AssetPlaybackManager.currentAssetDidChangeNotification, object: nil)
        }
    }
    
    // MARK: Initialization
    
    override init(){
        super.init()

        // Add the notification observer needed to respond to audio interruptions.
        NotificationCenter.default.addObserver(self, selector: #selector(AssetPlaybackManager.handleAudioSessionInterruption(notification:)), name: AVAudioSession.interruptionNotification, object: AVAudioSession.sharedInstance())
        
        // Add the Key-Value Observers needed to keep internal state of `AssetPlaybackManager` and `MPNowPlayingInfoCenter` in sync.
        player.addObserver(self, forKeyPath: #keyPath(AVPlayer.currentItem), options: [.initial, .new], context: nil)
    }
    
    deinit {
        // Remove all KVO and notification observers.
        
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.interruptionNotification, object: AVAudioSession.sharedInstance())
        
        player.removeObserver(self, forKeyPath: #keyPath(AVPlayer.currentItem), context: nil)
    }
    
    // MARK: Playback Control Methods.
    
    func play() {
        guard asset != nil else { return }
        
        if shouldResumePlaybackAfterInterruption == false {
            shouldResumePlaybackAfterInterruption = true
            
            return
        }
        
        player.play()
        if let onPlay = self.onPlay {
            onPlay()
        }
    }
    
    func pause() {
        guard asset != nil else { return }
        
        if state == .interrupted {
            shouldResumePlaybackAfterInterruption = false
            
            return
        }
        
        player.pause()
        if let onPause = self.onPause {
            onPause()
        }
    }
    
    func togglePlayPause() {
        guard asset != nil else { return }
        
        if player.rate == 1.0 {
            pause()
        }
        else {
            play()
        }
    }
    
    func stop() {
        guard asset != nil else { return }
        
        asset = nil
        playerItem = nil
        player.replaceCurrentItem(with: nil)
    }
    
    // MARK: MPNowPlayingInforCenter Management Methods
    
    // func updateGeneralMetadata() {
    //     guard player.currentItem != nil, let /*urlAsset*/_ = player.currentItem?.asset else {
    //         nowPlayingInfoCenter.nowPlayingInfo = nil
    //         return
    //     }
    // }
    
    // MARK: Notification Observing Methods

    @objc func handleAudioSessionInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo, let typeInt = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let interruptionType = AVAudioSession.InterruptionType(rawValue: typeInt) else { return }
        
        
        switch interruptionType {
            case .began:
                state = .interrupted
            case .ended:
                do {
                    try AVAudioSession.sharedInstance().setActive(true)
                    
                    if shouldResumePlaybackAfterInterruption == false {
                        shouldResumePlaybackAfterInterruption = true
                        
                        return
                    }
                    
                    guard let optionsInt = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
                    
                    let interruptionOptions = AVAudioSession.InterruptionOptions(rawValue: optionsInt)
                    
                    if interruptionOptions.contains(.shouldResume) {
                        play()
                    }
                }
                catch {
                    print("An Error occured activating the audio session while resuming from interruption: \(error)")
                }
                state = .initial
            default:
                print("unknown interruption type")
        }
    }
    
    // MARK: Key-Value Observing Method
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(AVURLAsset.isPlayable) {
            if asset.isPlayable {
                playerItem = AVPlayerItem(asset: asset)
                player.replaceCurrentItem(with: playerItem)
            }
        }
        else if keyPath == #keyPath(AVPlayerItem.status) {
            if playerItem.status == .readyToPlay {
                player.play()
            }
        }
        else if keyPath == #keyPath(AVPlayer.currentItem){
            
            // Cleanup if needed.
            if player.currentItem == nil {
                asset = nil
                playerItem = nil
            }
        }
        else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}
