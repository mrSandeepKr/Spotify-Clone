//
//  CategoryViewController.swift
//  SpoiftyClone
//
//  Created by Sandeep Kumar on 27/04/21.
//

import Foundation
import UIKit

class CategoryViewController: UIViewController {
    private var category: CategoryObject?
    private var playlists = [Playlist]()
    
    private var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { (_, _) -> NSCollectionLayoutSection? in
                                                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                                                                                     heightDimension: .fractionalHeight(1.0)))
                                                item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
                                                
                                                
                                                let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                                                                                                        heightDimension: .absolute(200)),
                                                                                                         subitem: item,
                                                                                                         count: 2)
                                                
                                                let section = NSCollectionLayoutSection(group: group)
                                                return section
        }))
        return collectionView
    }()
    
    init(with info : CategoryObject) {
        self.category = info
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = category?.name
        fetchData()
        configureCollectionView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
        collectionView.backgroundColor = . clear
    }
}

extension CategoryViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    func configureCollectionView() {
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(FeaturedPlaylistCollectionViewCell.self, forCellWithReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return playlists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier, for: indexPath) as? FeaturedPlaylistCollectionViewCell
        else {
            return UICollectionViewCell()
        }
        let info = self.playlists[indexPath.row]
        cell.configure(with: FeaturedPlaylistCellViewModel(name: info.name, artworkURL: URL(string: info.images?.first?.url ?? "")))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let vc = PlaylistViewController(with: playlists[indexPath.row])
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
        return
    }
    
}

extension CategoryViewController {
    func fetchData() {
        ApiCaller.shared.getPlaylistOfCategory(for: category?.id ?? "") { [weak self] res in
            switch res {
            case .success(let playlists):
                DispatchQueue.main.async {
                    self?.playlists = playlists
                    self?.collectionView.reloadData()
                }
            default:
                break
            }
        }
    }
}
