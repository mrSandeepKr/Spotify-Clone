//
//  PlaylistViewController.swift
//  SpoiftyClone
//
//  Created by Sandeep Kumar on 27/03/21.
//

// Video 12 end has the Share Button implementation need to read more about it.

import UIKit

class PlaylistViewController: UIViewController {
    private var playlist : Playlist
    private var audioTracks =  [TracksCellViewModel]()
    private var audioTracksArray = [AudioTrack]()
    private var owner = false
    
    private var collectionView = UICollectionView(frame: .zero,
                                                  collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { (_, _) -> NSCollectionLayoutSection? in
                                                    PlaylistViewController.configureAudioTrackCellLayout()
                                                  }))
    
    init(with playlist:Playlist ) {
        self.playlist = playlist
        self.owner = playlist.owner.id == Utils.getUserId()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = playlist.name
        view.backgroundColor = .systemGreen
        fetchdata()
        configureCollectionView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
}

// MARK:: CollectionView
extension PlaylistViewController : UICollectionViewDelegate, UICollectionViewDataSource{
    func configureCollectionView() {
        view.addSubview(collectionView)
        collectionView.backgroundColor = .systemBackground
        collectionView.register(AudioTracksCollectionViewCell.self, forCellWithReuseIdentifier: AudioTracksCollectionViewCell.identifier)
        collectionView.register(PlayButtonHeaderCollectionReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: PlayButtonHeaderCollectionReusableView.identifier)
        
        if owner {
            collectionView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(didLongTapCollectionView(_:))))
        }
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return audioTracks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AudioTracksCollectionViewCell.identifier, for: indexPath) as? AudioTracksCollectionViewCell
        else {
            return UICollectionViewCell()
        }
        cell.configure(with: audioTracks[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                           withReuseIdentifier: PlayButtonHeaderCollectionReusableView.identifier,
                                                                           for: indexPath) as? PlayButtonHeaderCollectionReusableView
        else {
            return UICollectionReusableView()
        }
        let playlistHeaderModel = PlayButtonHeaderViewModel(name: playlist.name,
                                                            desc: playlist.description ?? "",
                                                            owner: playlist.owner.display_name,
                                                            artworkURL: URL(string: playlist.images?.first?.url ?? ""),
                                                            placeholderImage: Utils.defaultPlaylistImage)
        header.configureView(viewModel: playlistHeaderModel)
        header.delegate = self
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        PlaybackPresenter.shared.startPlayback(from: self, with: audioTracksArray[indexPath.row])
    }
    
    @objc func didLongTapCollectionView(_ sender: UILongPressGestureRecognizer) {
        guard sender.state == .began,
              let indexPath = collectionView.indexPathForItem(at: sender.location(in: collectionView)) else {
            return
        }
        
        let alert = UIAlertController(title: "Remove \(audioTracks[indexPath.row].name)",
                                      message: "Would you like to Delete the track from your playlist?",
                                      preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {[weak self] _ in
            guard let audioTrackToDel = self?.audioTracksArray[indexPath.row], let playlistToDelFrom = self?.playlist
            else {
                return
            }
            
            ApiCaller.shared.removeTrackFromPlaylist(with: [audioTrackToDel],
                                                     from: playlistToDelFrom) {[weak self] res in
                switch res {
                case .success(_):
                    DispatchQueue.main.async {
                        self?.audioTracks.remove(at: indexPath.row)
                        self?.audioTracksArray.remove(at: indexPath.row)
                        self?.collectionView.reloadData()
                    }
                case .failure(_):
                    break
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: Utils
extension PlaylistViewController {
    private static func configureAudioTrackCellLayout()  -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        item.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 2, bottom: 1, trailing: 2)
        let group = NSCollectionLayoutGroup.vertical(layoutSize:NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                                                       heightDimension: .absolute(70)),
                                                     subitem: item,
                                                     count: 1)
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [
            NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                                                           heightDimension: .fractionalWidth(1.0)),
                                                        elementKind: UICollectionView.elementKindSectionHeader,
                                                        alignment: .top)]
        return section
    }
    
    private func fetchdata() {
        ApiCaller.shared.getPlaylistDetails(for: playlist) {[weak self] (res) in
            switch res {
            case .success(let res):
                DispatchQueue.main.async {
                    self?.audioTracks = res.tracks?.items.compactMap({
                        return TracksCellViewModel(name: $0.track.name ,
                                                   artistName: $0.track.artists.first?.name ?? "-",
                                                   artworkURL: URL(string: $0.track.album?.images?.first?.url ?? ""))
                    }) ?? []
                    
                    self?.audioTracksArray = res.tracks?.items.compactMap({ return $0.track}) ?? []
                    self?.collectionView.reloadData()
                }
                break
            default:
                break
            }
        }
    }
}

extension PlaylistViewController : PlayButtonHeaderCollectionReusableViewDelegate {
    func DidTapPlayAllInHeader() {
        PlaybackPresenter.shared.startPlayback(from: self,
                                        with: audioTracksArray)
    }
}
