//
//  ViewController.swift
//  SpoiftyClone
//
//  Created by Sandeep Kumar on 26/03/21.
//

import UIKit

enum HomeCollectionViewSectionType {
    case newReleases(viewModel: [NewReleaseCellViewModel])
    case featuredPlaylist(viewModel: [FeaturedPlaylistCellViewModel])
    case recommendedTracks(viewModel: [TracksCellViewModel])
}

class HomeViewController: UIViewController {
    private var collectionView: UICollectionView = UICollectionView(frame: .zero,
                                                                    collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { (sectionIndex, _) -> NSCollectionLayoutSection? in
                                                                        return HomeViewController.createSectionLayout(section: sectionIndex)
                                                                    }))
    
    //    private let spinner : UIActivityIndicatorView = {
    //        let spinner = UIActivityIndicatorView()
    //        spinner.tintColor = .label
    //        spinner.hidesWhenStopped = true
    //        return spinner
    //    }()
    
    private var hadDataFetchFailed = false
    private var sections = [HomeCollectionViewSectionType]()
    private var fullNewReleaseAlbums = [Album]()
    private var fullFeaturedPlaylist = [Playlist]()
    private var fullRecommendedTracks = [AudioTrack]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Browse"
        
        fetchData()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"),
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapSettings))
        
        self.configureCollectionView()
        //self.configureSpinnerView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if(hadDataFetchFailed) {
            print("HomeViewController: Trying Data Refresh")
            fetchData()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    @objc func didTapSettings() {
        let vc = SettingsViewController()
        vc.title = "Profile"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: CollectionViewDelegation
extension HomeViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    private func configureCollectionView() {
        view.addSubview(collectionView)
        collectionView.backgroundColor = .systemBackground
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.register(NewReleasesCollectionViewCell.self, forCellWithReuseIdentifier: NewReleasesCollectionViewCell.identifier)
        collectionView.register(FeaturedPlaylistCollectionViewCell.self, forCellWithReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier)
        collectionView.register(AudioTracksCollectionViewCell.self, forCellWithReuseIdentifier: AudioTracksCollectionViewCell.identifier)
        collectionView.register(SectionTitleCollectionReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: SectionTitleCollectionReusableView.identifier)
        
        collectionView.isUserInteractionEnabled = true
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(didLongTapCollectionView(_:)))
        collectionView.addGestureRecognizer(gesture)
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let type = sections[section]
        switch type {
        case .newReleases(let viewModel):
            return viewModel.count
        case .featuredPlaylist(let viewModel):
            return viewModel.count
        case .recommendedTracks(let viewModel):
            return viewModel.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let type = sections[indexPath.section]
        
        switch type {
        
        case .newReleases(let viewModels):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewReleasesCollectionViewCell.identifier, for: indexPath) as? NewReleasesCollectionViewCell
            else {
                return UICollectionViewCell()
            }
            cell.configure(with: viewModels[indexPath.row])
            return cell
            
        case .featuredPlaylist(let viewModels):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier, for: indexPath) as? FeaturedPlaylistCollectionViewCell
            else {
                return UICollectionViewCell()
            }
            
            cell.configure(with: viewModels[indexPath.row])
            return cell
            
        case .recommendedTracks(let viewModels):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AudioTracksCollectionViewCell.identifier, for: indexPath) as? AudioTracksCollectionViewCell
            else {
                return UICollectionViewCell()
            }
            cell.configure(with: viewModels[indexPath.row])
            return cell
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    private static func createSectionLayout(section: Int) -> NSCollectionLayoutSection {
        switch section {
        case 0:
            return HomeViewController.createSectionLayoutForNewReleases()
        case 1:
            return HomeViewController.createSectionLayoutForFeaturedPlaylist()
        case 2:
            return HomeViewController.createSectionLayoutForRecommendedSection()
        default:
            return HomeViewController.createSectionLayoutDefault()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind ==  UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionTitleCollectionReusableView.identifier, for: indexPath) as?  SectionTitleCollectionReusableView
        else {
            return UICollectionReusableView()
        }
        let sectionType = sections[indexPath.section]
        var sectionTile = ""
        switch sectionType {
        case .newReleases:
            sectionTile = "New Releases"
            break
        case .featuredPlaylist:
            sectionTile = "Featured Playlist"
            break
        case .recommendedTracks:
            sectionTile = "Recommended Tracks"
            break
        }
        header.configureHeader(viewModel: SectionTitleViewModel(sectionTitle: sectionTile))
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        HapticsManager.shared.vibrateForSelection()
        collectionView.deselectItem(at: indexPath, animated: true)
        let sectionType = sections[indexPath.section]
        
        switch sectionType {
        
        case .newReleases:
            presentAlbumViewController(for: indexPath.row)
            break
        case .featuredPlaylist:
            presentPlaylistViewController(for: indexPath.row)
            break
        case .recommendedTracks:
            PlaybackPresenter.shared.startPlayback(from: self,
                                                   with: fullRecommendedTracks[indexPath.row])
            break
        }
    }
    
    @objc func didLongTapCollectionView(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began,
              let indexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)),
              indexPath.section == 2
        else {
            return
        }
        
        let actionSheet = UIAlertController(title: "Add to Playlist",
                                            message: "Would you prefer to add this to one of your playlist ",
                                            preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Yup!", style: .default, handler: { [weak self] _ in
            let vc = LibraryPlaylistViewController(entryPoint: .addTrackToPlaylist,
                                                   track:self?.fullRecommendedTracks[indexPath.row])
            vc.setUpWithLargeTitleDisplayMode(titleText: "Choose a the playlist")
            let nv = UINavigationController(rootViewController: vc)
            self?.present(nv, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        
        present(actionSheet, animated: true, completion: nil)
    }
}

// MARK:- CollectionViewLayout
extension HomeViewController {
    private static func createSectionLayoutForNewReleases() -> NSCollectionLayoutSection {
        let itemHeight = NSCollectionLayoutDimension.fractionalHeight(1.0)
        let itemWidth = NSCollectionLayoutDimension.fractionalWidth(1.0)
        
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: itemWidth, heightDimension: itemHeight))
        item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
        
        let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(360.0)),
                                                             subitem: item,
                                                             count: 3)
        
        let horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .absolute(360)),
                                                                 subitem: verticalGroup,
                                                                 count: 1)
        
        let section = NSCollectionLayoutSection(group: horizontalGroup)
        section.orthogonalScrollingBehavior = .continuous
        section.boundarySupplementaryItems = HomeViewController.getBoundarySupplementaryItems()
        
        return section
    }
    
    private static func createSectionLayoutForFeaturedPlaylist() -> NSCollectionLayoutSection {
        let itemHeight = NSCollectionLayoutDimension.absolute(200)
        let itemWidth = NSCollectionLayoutDimension.absolute(200)
        
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: itemWidth, heightDimension: itemHeight))
        item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
        
        let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(200), heightDimension: .absolute(400)),
                                                             subitem: item,
                                                             count: 2)
        
        let horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(200), heightDimension: .absolute(400)),
                                                                 subitem: verticalGroup,
                                                                 count: 1)
        
        let section = NSCollectionLayoutSection(group: horizontalGroup)
        section.orthogonalScrollingBehavior = .continuous
        section.boundarySupplementaryItems = HomeViewController.getBoundarySupplementaryItems()
        return section
    }
    
    private static func createSectionLayoutForRecommendedSection() -> NSCollectionLayoutSection {
        let itemHeight = NSCollectionLayoutDimension.fractionalHeight(1.0)
        let itemWidth = NSCollectionLayoutDimension.fractionalWidth(1.0)
        
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: itemWidth, heightDimension: itemHeight))
        item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(60)),
                                                     subitem: item,
                                                     count: 1)
        
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = HomeViewController.getBoundarySupplementaryItems()
        
        return section
    }
    
    private static func createSectionLayoutDefault() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(120.0)),
                                                     subitem: item,
                                                     count: 1)
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = HomeViewController.getBoundarySupplementaryItems()
        
        return section
    }
    
    private static func getBoundarySupplementaryItems() -> [NSCollectionLayoutBoundarySupplementaryItem] {
        return  [NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                                                                heightDimension: .absolute(50)),
                                                             elementKind: UICollectionView.elementKindSectionHeader,
                                                             alignment: .top)]
    }
}

// MARK: Cell Views
extension HomeViewController {
    private func presentAlbumViewController(for index: Int) {
        let vc = AlbumViewController(with: fullNewReleaseAlbums[index])
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func presentPlaylistViewController(for index: Int) {
        let vc = PlaylistViewController(with: fullFeaturedPlaylist[index])
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}

//// MARK:- Utils and Miscellaneous
//extension HomeViewController {
//    private func configureSpinnerView() {
//        view.addSubview(spinner)
//    }
//}

// MARK: DataLayer
extension HomeViewController {
    /*
     Fetch New Releases, Featured Playlist and Recommendations
     */
    private func fetchData() {
        let group = DispatchGroup()
        group.enter()
        group.enter()
        group.enter()
        
        var newReleases: NewReleaseResponse?
        var featuredPlaylists: FeaturedPlaylistResponse?
        var recommendedTracks: RecommendationResponse?
        
        ApiCaller.shared.getNewRelease {[weak self] result in
            defer {
                group.leave()
            }
            switch result {
            case .failure(_):
                self?.hadDataFetchFailed = true
                break
            case .success(let model):
                newReleases = model
                break
            }
        }
        
        ApiCaller.shared.getFeaturedPlaylists {[weak self] result in
            defer {
                group.leave()
            }
            switch result {
            case .failure(_):
                self?.hadDataFetchFailed = true
                break
            case .success(let model):
                featuredPlaylists = model
                break
            }
        }
        
        ApiCaller.shared.getRecommendedGenre(completion:{[weak self] result in
            switch result {
            case .failure(_):
                self?.hadDataFetchFailed = true
                break
            case .success(let model):
                var gen = Set<String>()
                while gen.count < 5 {
                    if let x = model.genres.randomElement() {
                        gen.insert(x)
                    }
                }
                let genres = gen.joined(separator: ",")
                ApiCaller.shared.getRecommendations(genreSeed: genres, completion: {result in
                    defer {
                        group.leave()
                    }
                    switch result {
                    case .failure(_): break
                    case .success(let model):
                        recommendedTracks = model
                        break
                    }
                })
                break
            }
        })
        
        group.notify(queue: .main){
            self.hadDataFetchFailed = false
            self.configureSectionsModel(newReleases: newReleases, featuresPlaylist: featuredPlaylists, recommendedTracks: recommendedTracks)
        }
    }
    
    func configureSectionsModel(newReleases: NewReleaseResponse?, featuresPlaylist: FeaturedPlaylistResponse?, recommendedTracks: RecommendationResponse?) {
        guard  let releases = newReleases?.albums.items,
               let playlists = featuresPlaylist?.playlists.items,
               let tracks = recommendedTracks?.tracks
        else {
            print("HomeViewController: Data is not available to show the sections")
            return
        }
        
        fullNewReleaseAlbums = releases
        fullFeaturedPlaylist = playlists
        fullRecommendedTracks = tracks
        sections = []
        
        sections.append(.newReleases(viewModel: releases.compactMap({
            return NewReleaseCellViewModel(name: $0.name,
                                           artworkURL: URL(string: $0.images?.first?.url ?? ""),
                                           numberOfTracks: $0.total_tracks ,
                                           artistName: $0.artists.first?.name ?? "")
        })))
        
        sections.append(.featuredPlaylist(viewModel: playlists.compactMap({
            return FeaturedPlaylistCellViewModel(name: $0.name,
                                                 artworkURL: URL(string: $0.images?.first?.url ?? ""))
        })))
        
        sections.append(.recommendedTracks(viewModel: tracks.compactMap({
            return TracksCellViewModel(name: $0.name,
                                       artistName: $0.artists.first?.name ?? "-",
                                       artworkURL: URL(string: $0.album?.images?.first?.url ?? ""))
        })))
        
        collectionView.reloadData()
    }
}
