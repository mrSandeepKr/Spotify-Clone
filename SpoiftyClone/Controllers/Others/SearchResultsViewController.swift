//
//  SearchResultsViewController.swift
//  SpoiftyClone
//
//  Created by Sandeep Kumar on 27/03/21.
//

import UIKit

protocol SearchResultsViewControllerDelegate: AnyObject {
    func handleSearchResultSelection(for searchResult: SearchResultDataObject)
}

class SearchResultsViewController: UIViewController {
    private var resultSections: [SearchResultsSection] = []
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        return tableView
    }()
    
    weak var delegate: SearchResultsViewControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        configureTableView()
    }
    
    override func viewDidLayoutSubviews() {
        view.addSubview(tableView)
        tableView.frame = view.bounds
    }
    
}

// MARK: TableView
extension SearchResultsViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultSections[section].info.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DefaultSearchResultTableViewCell.identifier,
                                                       for: indexPath) as? DefaultSearchResultTableViewCell
        else {
            return UITableViewCell()
        }
        
        let info = resultSections[indexPath.section].info[indexPath.row]
        var dataModel : DefaultSearchResultTableViewCellViewModel? = nil
        switch info {
        case .albums(let model):
            dataModel = DefaultSearchResultTableViewCellViewModel(title: model.name,
                                                                  artWorkUrl: URL(string: model.images?.first?.url ?? ""),
                                                                  subtitle: String.formattedDate(dateString: model.release_date))
            break
        case .playlists(let model):
            dataModel = DefaultSearchResultTableViewCellViewModel(title: model.name,
                                                                  artWorkUrl: URL(string: model.images?.first?.url ?? ""),
                                                                  subtitle: nil)
            
            break
        case .tracks(let model):
            dataModel = DefaultSearchResultTableViewCellViewModel(title: model.name,
                                                                  artWorkUrl: URL(string: model.album?.images?.first?.url ?? ""),
                                                                  subtitle: model.artists.first?.name ?? "-")
            
            break
        case .artists(let model):
            dataModel = DefaultSearchResultTableViewCellViewModel(title: model.name,
                                                                  artWorkUrl: URL(string: model.images?.first?.url ?? ""),
                                                                  subtitle: nil)
            
            break
        }
        cell.configure(with: dataModel)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return resultSections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return resultSections[section].title
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.delegate?.handleSearchResultSelection(for: resultSections[indexPath.section].info[indexPath.row])
    }
    
    func configureTableView() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(DefaultSearchResultTableViewCell.self, forCellReuseIdentifier: DefaultSearchResultTableViewCell.identifier)
    }
}

// MARK: Data
extension SearchResultsViewController {
    //reload the table view too
    func updateSearchResults(with results: [SearchResultDataObject]) {
        resultSections = []
        
        var albums = [SearchResultDataObject]()
        var playlists = [SearchResultDataObject]()
        var tracks = [SearchResultDataObject]()
        var artists = [SearchResultDataObject]()
        
        results.forEach { result in
            switch result {
            case .albums:
                albums.append(result)
                break
            case .playlists:
                playlists.append(result)
                break
            case .tracks:
                tracks.append(result)
                break
            case .artists:
                artists.append(result)
                break
            }
        }
        
        if (!albums.isEmpty) {
            resultSections.append(SearchResultsSection(title: "Albums", info: albums))
        }
        if (!playlists.isEmpty) {
            resultSections.append(SearchResultsSection(title: "Playlist", info: playlists))
        }
        if (!tracks.isEmpty) {
            resultSections.append(SearchResultsSection(title: "Tracks", info: tracks))
        }
        if (!artists.isEmpty) {
            resultSections.append(SearchResultsSection(title: "Artists", info: artists))
        }
        
        tableView.reloadData()
    }
}
