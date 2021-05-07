//
//  PlaybackPresenter.swift
//  SpoiftyClone
//
//  Created by Sandeep Kumar on 29/04/21.
//

import Foundation
import UIKit
import AVFoundation

final class PlaybackPresenter {
    static let shared = PlaybackPresenter()
    private var tracks = [AudioTrack]()
    private var player : AVPlayer?
    private var currentVol: Float = 0.5
    
    var currentTrack : AudioTrack? {
        if !tracks.isEmpty {
            return tracks.first
        }
        return nil
    }
    
    func startPlayback(from vc: UIViewController,
                    with track: AudioTrack)
    {
        startPlayback(from: vc,
                      with: [track])
    }
    
    func startPlayback(from vc: UIViewController,
                   with tracks: [AudioTrack])
    {
        self.tracks = tracks
        
        configurePlayerWithUrl(with: self.tracks.first?.preview_url)
        
        let playerController = PlayerViewController()
        playerController.dataSource = self
        playerController.delegate = self
        vc.present(UINavigationController(rootViewController: playerController), animated: true, completion: nil)
    }
    
    private func configurePlayerWithUrl(with string: String?){
        guard let urlstring = string, let url =  URL(string: urlstring)
        else {
            let alert = UIAlertController(title: "Song Not Available",
                                          message: "Preview Url for this song is empty",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Play Next", style: .default , handler: {[weak self] _ in
                self?.didTapNextButton()
            }))
            return
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            player = AVPlayer(url: url)
        } catch {
            print("some thing went wrong: \(error)")
        }
        player?.volume = currentVol
        player?.play()
    }
}

extension PlaybackPresenter: PlayerViewControllerDataSource, PlayerViewControllerDelegate {

    func didTapNextButton() {
        let track = tracks[0]
        player?.pause()
        tracks.remove(at: 0)
        tracks.append(track)
        configurePlayerWithUrl(with: tracks.first?.preview_url)
    }
    
    func didTapBackButton() {
        guard let track = tracks.last
        else {return}
        player?.pause()
        tracks.removeLast()
        tracks.insert(track, at: 0)
        configurePlayerWithUrl(with: tracks.first?.preview_url)
    }
    
    func didTapPlayPauseButton() {
        if player?.timeControlStatus == .playing {
            player?.pause()
        }
        else {
            player?.play()
        }
    }
    
    func didChangeVolume(with value: Float) {
        if let player = player {
            player.volume = value
            currentVol = value
        }
    }
    
    func stopTheMusic() {
        player?.pause()
    }
    var trackTitle: String? {
        return currentTrack?.name
    }
    
    var trackDesc: String? {
        return currentTrack?.artists.first?.name
    }
    
    var artworkURL: URL? {
        return URL(string: currentTrack?.album?.images?.first?.url ?? "")
    }
}
