import UIKit

final class SearchCoordinator: CoordinatorDescribing {
    
    // MARK: - Properties
    var childCoordinators: [CoordinatorDescribing] = []
    var navigationController: UINavigationController?
    private var movieSearchViewController: MovieSearchViewController!
    
    // MARK: - Initializers
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
    
    // MARK: - Methods
    func start() {
        let movieSearchViewModel = MovieSearchViewModel(coordinator: self)
        movieSearchViewController = MovieSearchViewController(viewModel: movieSearchViewModel)
        
        navigationController?.pushViewController(movieSearchViewController, animated: true)
    }
    
    func showDetailPage(with information: (CellItem, IndexPath)) {
        let detailCoordinator = DetailCoordinator(navigationController: navigationController)
        childCoordinators.append(detailCoordinator)
        detailCoordinator.delegate = self
        
        detailCoordinator.start(with: information, delegatee: movieSearchViewController)
    }
    
    func showFavoritesPage(with favoriteMovies: [Movie]) {
        let favoritesCoordinator = FavoritesCoordinator(navigationController: navigationController)
        childCoordinators.append(favoritesCoordinator)
        favoritesCoordinator.delegate = self
        
        favoritesCoordinator.start(with: favoriteMovies)
    }
    
}

// MARK: - DetailCoordinator Delegate
extension SearchCoordinator: ChildCoordinatorDelegate {
    
    func removeFromChildCoordinators(coordinator: CoordinatorDescribing) {
        let updatedChildCoordinators = childCoordinators.filter { $0 !== coordinator }
        childCoordinators = updatedChildCoordinators
    }
    
}
