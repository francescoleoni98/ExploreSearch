import UIKit

class ViewController: UITableViewController {
  
  private var items: [String] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    mockAsyncCall {
      self.items = (0...100).map { "Explore \($0)" }
      self.tableView.reloadData()
    }
    
    let recentSearchesController = RecentSearchesController(navigation: navigationController)
    let searchController = UISearchController(searchResultsController: recentSearchesController)
    searchController.searchResultsUpdater = recentSearchesController
    searchController.showsSearchResultsController = true
    
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

    navigationItem.searchController = searchController
  }
}

extension ViewController {
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    cell.textLabel?.text = items[indexPath.item]
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let text = items[indexPath.item]
    navigationController?.pushViewController(DetailsVC(text: text), animated: true)
  }
}



class RecentSearchesController: UITableViewController {
  
  private let debouncer = Debouncer(timeInterval: 0.5)
  private let navigation: UINavigationController?
  private var isSearching: Bool = false
  private var recentSearches: [String] = []
  private var searchResults: [String] = []
  
  init(navigation: UINavigationController?) {
    self.navigation = navigation
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    mockAsyncCall {
      self.recentSearches = (0...100).map { "Recent \($0)" }
      self.tableView.reloadData()
    }
    
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return isSearching ? searchResults.count : recentSearches.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    cell.textLabel?.text = isSearching ? searchResults[indexPath.item] : recentSearches[indexPath.item]
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let text = isSearching ? searchResults[indexPath.item] : recentSearches[indexPath.item]
    navigationController?.pushViewController(DetailsVC(text: text), animated: true)
  }
}

extension RecentSearchesController: UISearchResultsUpdating {
  
  func updateSearchResults(for searchController: UISearchController) {
    guard let searchText = searchController.searchBar.text?.lowercased() else { return }
    
    if searchText.isEmpty || searchText == "" {
      self.isSearching = false
      self.tableView.reloadData()
      self.tableView.backgroundView = nil
    } else {
      self.searchResults = []
      self.isSearching = true
      self.tableView.reloadData()
      self.tableView.backgroundView = loadingView()

      debouncer.perform {
        /*
         Chiamata che ritorna risultati in base al `searchText`
         */
        mockFilteredResults(text: searchText) { results in
          self.tableView.backgroundView = nil
          self.searchResults = results
          self.tableView.reloadData()
        }
      }
    }
  }
}


// MARK: - Helpers

func loadingView() -> UIView {
  let container = UIView()
  let loader = UIActivityIndicatorView(style: .medium)
  container.addSubview(loader)
  loader.translatesAutoresizingMaskIntoConstraints = false
  loader.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
  loader.topAnchor.constraint(equalTo: container.safeAreaLayoutGuide.topAnchor, constant: 50).isActive = true
  loader.startAnimating()
  return container
}

func mockAsyncCall(_ perform: @escaping () -> Void) {
  DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: perform)
}

func mockFilteredResults(text: String, _ perform: @escaping ([String]) -> Void) {
  let allItems = (0...1000).map { "Result \($0)" }
  
  mockAsyncCall {
    perform(allItems.filter { $0.lowercased().contains(text) })
  }
}
