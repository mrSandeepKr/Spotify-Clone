//
//  LibraryAlbumViewController.swift
//  SpoiftyClone
//
//  Created by Sandeep Kumar on 02/05/21.
//

import UIKit

class LibraryAlbumViewController: UIViewController {
    private var albums: [Album] = []
    
    private let collectionView : UICollectionView = {
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { _, _ in
                                                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(200)))
                                                item.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 3, bottom: 1, trailing: 2)
                                                let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                                                                                                  heightDimension: .absolute(200)),
                                                                                               subitem: item,
                                                                                               count: 2)
                                                let section = NSCollectionLayoutSection(group: group)
                                                return section
                                              }))
        collectionView.isHidden = true
        return collectionView
    }()
    
    private var observer : NSObjectProtocol?
    
    private let albumNoDataView = LibraryNoDataView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureCollectionView()
        configureNoAlbumView()
        fetchData()
        observer = NotificationCenter.default.addObserver(forName: .albumSavedNotification,
                                                          object: nil,
                                                          queue: .main, using: { [weak self] _ in
                                                            self?.fetchData()
                                                          })
    }
    
    private func updateUIIfNeeded() {
        if albums.isEmpty {
            collectionView.isHidden = true
            albumNoDataView.isHidden = false
        } else {
            albumNoDataView.isHidden = true
            collectionView.isHidden = false
            collectionView.reloadData()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
        albumNoDataView.frame = CGRect(x: view.width/4, y: (view.height - 300)/2, width: view.width/2, height: 300)
    }
}

extension LibraryAlbumViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    private func configureCollectionView() {
        view.addSubview(collectionView)
        collectionView.isHidden = true
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.register(FeaturedPlaylistCollectionViewCell.self, forCellWithReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier,
                                                         for: indexPath) as? FeaturedPlaylistCollectionViewCell
        else {
            return UICollectionViewCell()
        }
        
        let albumToShow = albums[indexPath.row]
        cell.configure(with: FeaturedPlaylistCellViewModel(name: albumToShow.name,
                                                           artworkURL:  URL(string: albumToShow.images?.first?.url ?? "")))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let vc = AlbumViewController(with: albums[indexPath.row])
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension LibraryAlbumViewController: LibraryNoDataViewDelegate {
    func libraryNoDataViewDidTapAction() {
        tabBarController?.selectedIndex = 0
    }
    
    private func configureNoAlbumView() {
        view.addSubview(albumNoDataView)
        albumNoDataView.configureView(with: LibraryNoDataViewModel(textLabelMessage: "You haven't followed any albums try following some",
                                                                   btnTitle: "Follow"))
        albumNoDataView.isHidden = true
        albumNoDataView.delegate = self
    }
}
extension LibraryAlbumViewController {
    private func fetchData() {
        self.albums.removeAll()
        ApiCaller.shared.getSavedUserAlbums {[weak self] res in
            switch res {
            case .success(let albums):
                DispatchQueue.main.async {
                    self?.albums = albums
                    self?.updateUIIfNeeded()
                }
                break
            default:
                break
            }
        }
    }
}
