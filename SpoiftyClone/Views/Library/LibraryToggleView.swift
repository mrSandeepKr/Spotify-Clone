//
//  LibraryToggleView.swift
//  SpoiftyClone
//
//  Created by Sandeep Kumar on 02/05/21.
//

import UIKit

protocol LibraryToggleViewDelegate : AnyObject {
    func libraryToggleViewDidTapPlayList()
    func libraryToggleViewDidTapAlbum()
}

class LibraryToggleView: UIView {
    // MARK: Public
    weak var delegate: LibraryToggleViewDelegate?
    
    func updateIndicatorWithAnimation(for state:State) {
        if viewState == state {
            return
        }
        
        viewState = state
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            switch state {
            case .album:
                self.addIndicator(for: .album)
                self.playlistBtn.backgroundColor = .systemGray3
                self.albumBtn.backgroundColor = .systemGray
            case .playList:
                self.addIndicator(for: .playList)
                self.playlistBtn.backgroundColor = .systemGray
                self.albumBtn.backgroundColor = .systemGray3
            }
        }
    }
    
    // MARK: Elements
    private let playlistBtn: UIButton = {
        let btn = UIButton.withAutoLayout()
        btn.setTitle("Playlist", for: .normal)
        btn.setTitleColor(.label, for: .normal)
        btn.backgroundColor = .systemGray
             
        btn.addTarget(self, action: #selector(playlisyButtonTapped), for: .touchUpInside)
        return btn
    }()
    
    private let albumBtn: UIButton = {
        let btn = UIButton.withAutoLayout()
        btn.setTitle("Album", for: .normal)
        btn.setTitleColor(.label, for: .normal)
        btn.backgroundColor = .systemGray3
        
        btn.addTarget(self, action: #selector(albumButtonTapped), for: .touchUpInside)
        return btn
    }()
    
    private let indicatorBar: UIView = {
        let view = UIView.withAutoLayout()
        view.layer.borderWidth = 2
        view.backgroundColor = .systemGreen
        view.layer.borderColor = UIColor.systemGreen.cgColor
        return view
    }()
    
    // MARK: Override
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setUpViews()
    }
    
    // MARK: Private
    enum State {
        case playList
        case album
    }
    
    var viewState : State = .playList
    
    @objc private func playlisyButtonTapped() {
        if viewState == .playList {
            return
        }
        
        delegate?.libraryToggleViewDidTapPlayList()
        self.updateIndicatorWithAnimation(for: .playList)
    }
    
    @objc private func albumButtonTapped() {
        if(viewState == .album) {
            return
        }
        
        delegate?.libraryToggleViewDidTapAlbum()
        self.updateIndicatorWithAnimation(for: .album)
    }
    
    private func setUpViews() {
        backgroundColor = .systemBackground
        addSubview(playlistBtn)
        addSubview(albumBtn)
        addSubview(indicatorBar)
        addIndicator(for: .playList)
        NSLayoutConstraint.activate(staticViewConstraints())
    }
    
    private func staticViewConstraints() -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(contentsOf: [
            playlistBtn.heightAnchor.constraint(equalToConstant: height/1.5),
            playlistBtn.leadingAnchor.constraint(equalTo: leadingAnchor),
            playlistBtn.bottomAnchor.constraint(equalTo: bottomAnchor,constant: CGFloat(-3)),
            playlistBtn.widthAnchor.constraint(equalToConstant: CGFloat(100)),
        ])
        
        constraints.append(contentsOf: [
            albumBtn.heightAnchor.constraint(equalToConstant: height/1.5),
            albumBtn.leadingAnchor.constraint(equalTo: playlistBtn.trailingAnchor, constant: CGFloat(1)),
            albumBtn.bottomAnchor.constraint(equalTo: bottomAnchor,constant: CGFloat(-3)),
            albumBtn.widthAnchor.constraint(equalToConstant: CGFloat(100))
        ])
        
        return constraints
    }
    
    private func addIndicator(for state: State) {
        switch viewState {
        case .playList:
            indicatorBar.frame = CGRect(x: 0,
                                        y: height - 3,
                                        width: 100,
                                        height: 3)
            break
        case .album:
            indicatorBar.frame = CGRect(x: albumBtn.left,
                                        y: height - 3,
                                        width: 100,
                                        height: 3)
            break
        }
    }
}
