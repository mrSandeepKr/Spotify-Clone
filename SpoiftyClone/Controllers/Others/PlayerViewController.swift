//
//  PlayerViewController.swift
//  SpoiftyClone
//
//  Created by Sandeep Kumar on 27/03/21.
//

import UIKit
import SDWebImage

protocol PlayerViewControllerDataSource : AnyObject {
    var trackTitle : String? {get}
    var trackDesc: String? {get}
    var artworkURL: URL? {get}
}

protocol PlayerViewControllerDelegate : AnyObject {
    func didTapNextButton()
    func didTapBackButton()
    func didTapPlayPauseButton()
    func didChangeVolume(with value: Float)
    func stopTheMusic()
}

class PlayerViewController: UIViewController {
    private let imageView : UIImageView  = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .systemPink
        return imageView
    }()
    
    private let controlView = PlayerControlView()
    weak var dataSource : PlayerViewControllerDataSource?
    weak var delegate : PlayerViewControllerDelegate?
    private var isPlaying = true;
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(imageView)
        view.addSubview(controlView)
        controlView.delegate = self
        configureBarButtons()
        configureViewDetails()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let imgSize = view.height * 0.4
        imageView.frame = CGRect(x: (view.width - imgSize) / 2.0,
                                 y: view.safeAreaInsets.top,
                                 width: imgSize,
                                 height: imgSize)
        
        controlView.frame = CGRect(x: 10,
                                   y: imageView.bottom + 30,
                                   width: view.width - 20 ,
                                   height: view.height - imageView.bottom - view.safeAreaInsets.bottom - 15)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate?.stopTheMusic()
    }

    private func configureBarButtons() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didTapAction))
    }
    
    private func configureViewDetails() {
        imageView.sd_setImage(with: dataSource?.artworkURL, completed: nil)
        controlView.configureView(title: dataSource?.trackTitle ?? "",
                                  subTile: dataSource?.trackDesc ?? "")
    }
    
    @objc private func didTapClose() {
        self.dismiss(animated: true) {[weak self] in
            self?.delegate?.stopTheMusic()
        }
    }
    
    @objc private func didTapAction() {
        return
    }
}

extension PlayerViewController :  PlayerControlViewDelegate {
    func playerControlViewDidChangeVolume(with value: Float) {
        delegate?.didChangeVolume(with: value)
    }
    
    // gets when we change the song or stop it.
    func playerControlViewDidTapPlayPause(_ playControlView: PlayerControlView) {
        delegate?.didTapPlayPauseButton()
        isPlaying = !isPlaying
        playControlView.updatePlayPauseButton(for: self.isPlaying)
    }
    
    func playerControlViewDidTapNextButton(_ playControlView: PlayerControlView) {
        delegate?.didTapNextButton()
        configureViewDetails()
    }
    
    func playerControlViewDidTapPrevButton(_ playControlView: PlayerControlView) {
        delegate?.didTapBackButton()
        configureViewDetails()
    }
}
