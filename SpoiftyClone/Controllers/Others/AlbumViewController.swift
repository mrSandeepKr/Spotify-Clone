//
//  AlbumViewController.swift
//  SpoiftyClone
//
//  Created by Sandeep Kumar on 24/04/21.
//

import UIKit

class AlbumViewController: UIViewController {
    private var album : Album
    private var albumDetails : FetchAlbumDetailsResponse?
    private var trackViewDetails = [TracksCellViewModel]()
    private var isAlbumSaved = false
    
    private let collectionView = UICollectionView(frame: .zero,
                                                  collectionViewLayout: UICollectionViewCompositionalLayout.init(sectionProvider: { (_, _) -> NSCollectionLayoutSection? in
                                                    return AlbumViewController.createAlbumTrackSectionLayout()
                                                  }))
    
    init(with album:Album) {
        self.album = album
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = album.name
        fetchData()
        checkIfAlbumSavedAndUpdateUI()
        configureRightBarButtonItem()
        configureCollectionView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
}

//MARK: CollectionView
extension AlbumViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trackViewDetails.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AudioTracksWithouImageCollectionViewCell.identifier, for: indexPath) as? AudioTracksWithouImageCollectionViewCell
        else {
            return UICollectionViewCell()
        }
        cell.configure(with: trackViewDetails[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: PlayButtonHeaderCollectionReusableView.identifier, for: indexPath) as? PlayButtonHeaderCollectionReusableView
        else {
            return UICollectionReusableView()
        }
        
        header.configureView(viewModel: PlayButtonHeaderViewModel(name: album.name,
                                                                  desc: "Release Date: \(String.formattedDate(dateString: album.release_date))",
                                                                  owner: album.artists.first?.name ?? "-",
                                                                  artworkURL: URL(string: album.images?.first?.url ?? ""),
                                                                  placeholderImage: nil))
        header.delegate = self
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        var track = self.albumDetails?.tracks.items[indexPath.row]
        track?.album = album
        
        PlaybackPresenter.shared.startPlayback(from: self,
                                               with: track!)
    }
    
    private func configureCollectionView() {
        view.addSubview(collectionView)
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(AudioTracksWithouImageCollectionViewCell.self, forCellWithReuseIdentifier: AudioTracksWithouImageCollectionViewCell.identifier)
        collectionView.register(PlayButtonHeaderCollectionReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: PlayButtonHeaderCollectionReusableView.identifier)
    }
}

//MARK: DataLayer
extension AlbumViewController {
    private static func createAlbumTrackSectionLayout() -> NSCollectionLayoutSection {
        let item  = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(60)))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                                                        heightDimension: .absolute(60)),
                                                     subitem: item,
                                                     count: 1)
        
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                                                                                             heightDimension: .fractionalWidth(1.0)),
                                                                                          elementKind: UICollectionView.elementKindSectionHeader,
                                                                                          alignment: .top)]
        return section
    }
    
    private func fetchData() {
        ApiCaller.shared.getAlbumDetails(for: album) {[weak self] res in
            switch res {
            case .success(let res):
                DispatchQueue.main.async {
                    self?.albumDetails = res
                    self?.trackViewDetails = res.tracks.items.compactMap({
                        return TracksCellViewModel(name: $0.name, artistName: $0.artists.first?.name ?? "-", artworkURL: URL(string: ""))
                    })
                    self?.collectionView.reloadData()
                }
            default:
                break
            }
        }
    }
    
    private func checkIfAlbumSavedAndUpdateUI(){
        ApiCaller.shared.checkIfAlbumsAreSaved(for: [album]) {[weak self] res in
            switch res {
            case .success(let isSaved):
                DispatchQueue.main.async {
                    guard let isSaved = isSaved.first else {return}
                    if isSaved != self?.isAlbumSaved {
                        self?.isAlbumSaved = isSaved
                        self?.configureRightBarButtonItem()
                    }
                }
                break
            case .failure(_):
                break
            }
        }
    }
}

//MARK: PlayAll Deletegate
extension AlbumViewController : PlayButtonHeaderCollectionReusableViewDelegate {
    func DidTapPlayAllInHeader() {
        let tracks : [AudioTrack] = self.albumDetails?.tracks.items ?? [AudioTrack]()
        let tracksWithAlbum : [AudioTrack] = tracks.compactMap({
            var track = $0
            track.album = album
            return track
        })
        
        PlaybackPresenter.shared.startPlayback(from: self,
                                               with: tracksWithAlbum)
    }
}

//MARK: Handling Album Save
extension AlbumViewController {
    private func configureRightBarButtonItem() {
        let button = BounceButton()
        if isAlbumSaved {
            button.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            button.tintColor = .systemGreen
        }
        else {
            button.setImage(UIImage(systemName: "heart"), for: .normal)
            button.tintColor = .label
        }
        button.addTarget(self, action: #selector(didTapAlbumSaveButton), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    @objc private func didTapAlbumSaveButton() {
        if isAlbumSaved {
            isAlbumSaved = false
            configureRightBarButtonItem()
        }
        else {
            isAlbumSaved = true
            configureRightBarButtonItem()
        }
        
        DispatchQueue.background(delay: 0.0, background: {[weak self] in
            guard let album = self?.album, let isSaving = self?.isAlbumSaved  else {
                return
            }
            ApiCaller.shared.modifySavedAlbums(for: [album],
                                               isSaving: isSaving) { res in
                switch res {
                case .success(let success):
                    if success {
                        HapticsManager.shared.vibrate(for: .success)
                        NotificationCenter.default.post(name: .albumSavedNotification, object: nil)
                    }
                    break
                case .failure:
                    HapticsManager.shared.vibrate(for: .error)
                    break
                }
            }
        }, completion: nil)
    }
}

class BounceButton: UIButton {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        super.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        
        UIView.animate(withDuration: 1,
                       delay: 0.0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 6,
                       options: .allowUserInteraction, animations: {
                        self.transform = .identity
                       })
    }
}
