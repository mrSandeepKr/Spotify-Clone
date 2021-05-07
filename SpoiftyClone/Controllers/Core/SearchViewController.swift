//
//  SearchViewController.swift
//  SpoiftyClone
//
//  Created by Sandeep Kumar on 27/03/21.
//

import UIKit
import SafariServices

class SearchViewController: UIViewController {
    private var categories = [CategoryObject]()
    //private var searchResults = FetchSearchResultsResponse(albums: nil, artists: nil, playlists: nil, tracks: nil)
    
    let searchController: UISearchController = {
        let res = SearchResultsViewController()
        let searchController = UISearchController(searchResultsController: res)
        searchController.searchBar.placeholder = "Songs, Artists, Albums"
        searchController.searchBar.searchBarStyle = .minimal
        searchController.definesPresentationContext = true
        return searchController
    }()
    
    let collectionView: UICollectionView = {
        let collectionView =  UICollectionView(frame: .zero,
                                               collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { (_, _) -> NSCollectionLayoutSection? in
                                                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                                                                                     heightDimension: .fractionalHeight(1.0)))
                                                item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 6, bottom: 2, trailing: 6)
                                                let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                                                                                                  heightDimension: .absolute(140)),
                                                                                               subitem: item,
                                                                                               count: 2)
                                                group.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)
                                                let section = NSCollectionLayoutSection(group: group)
                                                return section
                                               }))
        
        collectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier)
        collectionView.backgroundColor = .systemBackground
        return collectionView
    }()
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Search"
        view.backgroundColor = .systemBackground
        configureSearchView()
        configureCategoryView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if(categories.isEmpty) {
            fetchData()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
}

// MARK: UISearchResultsUpdating
extension SearchViewController: UISearchBarDelegate {
    func configureSearchView() {
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchTerm = searchBar.text?.trimmingCharacters(in: .whitespaces), !searchTerm.isEmpty,
              let searchResultsController = searchController.searchResultsController as? SearchResultsViewController
        else {
            print("SearchViewController: Invalid Search Term")
            return
        }
        
        searchResultsController.delegate = self
        
        triggerSearch(with: searchTerm) {res in
            searchResultsController.updateSearchResults(with: res)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        guard let searchResultsController = self.searchController.searchResultsController as? SearchResultsViewController
        else {
            return
        }
        
        searchResultsController.updateSearchResults(with: [])
    }
}

//MARK: CollectionView
extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func configureCategoryView() {
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.identifier, for: indexPath) as? CategoryCollectionViewCell
        else {
            return UICollectionViewCell()
        }
        let info = CategoryViewCellViewModel(label: categories[indexPath.row].name, url: URL(string: categories[indexPath.row].icons.first?.url ?? ""))
        cell.configureCell(viewModel: info)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let info = categories[indexPath.row]
        let vc = CategoryViewController(with: info)
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension SearchViewController: SearchResultsViewControllerDelegate {
    
    func handleSearchResultSelection(for searchResult: SearchResultDataObject){
        switch searchResult {
        case .albums(let model):
            let vc = AlbumViewController(with: model)
            vc.setUpWithLargeTitleDisplayModerNever()
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case .playlists(let model):
            let vc = PlaylistViewController(with: model)
            vc.setUpWithLargeTitleDisplayModerNever()
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case .artists(let model):
            let vc = ArtistViewController(with: model)
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case .tracks(let model):
            PlaybackPresenter.shared.startPlayback(from: self,
                                                   with: model)
            break
        }
    }
}

// MARK: DataLayer
extension SearchViewController {
    
    func fetchData() {
        ApiCaller.shared.getAllCategories {[weak self] (res) in
            switch res {
            case .success(let categories):
                DispatchQueue.main.async {
                    self?.categories = categories
                    self?.collectionView.reloadData()
                }
            default:
                break
            }
        }
    }
    
    func triggerSearch(with searchTerm: String, completion: @escaping ([SearchResultDataObject]) -> Void) {
        ApiCaller.shared.getSearchResults(for: searchTerm) { res in
            switch res {
            case .success(let res):
                DispatchQueue.main.async {
                    completion(res) 
                }
                break
            default:
                break
            }
        }
    }
}
