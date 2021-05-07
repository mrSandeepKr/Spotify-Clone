//
//  LibraryViewController.swift
//  SpoiftyClone
//
//  Created by Sandeep Kumar on 27/03/21.
//

import UIKit

class LibraryViewController: UIViewController {
    //MARK: Views
    private lazy var playlistView = LibraryPlaylistViewController(entryPoint: .libraryView)
    private lazy var albumView = LibraryAlbumViewController()
    private lazy var libraryToggleView = LibraryToggleView.withAutoLayout()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView: UIScrollView = UIScrollView.withAutoLayout()
        scrollView.isPagingEnabled = true
        scrollView.contentSize = CGSize(width: view.width * 2.0, height: scrollView.height)
        return scrollView
    }()
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Library"
        
        view.addSubview(libraryToggleView)
        view.addSubview(scrollView)
        libraryToggleView.delegate = self
        scrollView.delegate = self
        addChildViews()
        updateBarButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        NSLayoutConstraint.activate(staticViewContraints())
    }
    
    //MARK: Private
    private func addChildViews() {
        addChild(playlistView)
        scrollView.addSubview(playlistView.view)
        playlistView.view.frame = CGRect(x: 0, y: 0, width: scrollView.width, height: scrollView.height)
        playlistView.didMove(toParent: self)
        
        addChild(albumView)
        scrollView.addSubview(albumView.view)
        albumView.view.frame = CGRect(x: view.width, y: 0, width: scrollView.width, height: scrollView.height)
        albumView.didMove(toParent: self)
    }
    
    private func updateBarButton() {
        switch libraryToggleView.viewState {
        case .playList:
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"),
                                                                style: .plain,
                                                                target: self,
                                                                action: #selector(didTapAddPlaylist))
        case .album:
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    @objc private func didTapAddPlaylist() {
        playlistView.showCreatePlaylistAlert()
    }
    
    private func staticViewContraints() -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(contentsOf: [
            libraryToggleView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            libraryToggleView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: CGFloat(10)),
            libraryToggleView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: CGFloat(55.0)),
            libraryToggleView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        constraints.append(contentsOf: [
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor , constant: CGFloat(55.0)),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        return constraints
    }
}

extension LibraryViewController : LibraryToggleViewDelegate, UIScrollViewDelegate {
    func libraryToggleViewDidTapPlayList() {
        scrollView.setContentOffset(.zero, animated: false)
        updateBarButton()
    }
    
    func libraryToggleViewDidTapAlbum() {
        scrollView.setContentOffset(CGPoint(x: view.width, y: 0), animated: false)
        updateBarButton()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x >  view.width / 2.0 {
            libraryToggleView.updateIndicatorWithAnimation(for: .album)
            updateBarButton()
        } else {
            libraryToggleView.updateIndicatorWithAnimation(for: .playList)
            updateBarButton()
        }
    }
}
