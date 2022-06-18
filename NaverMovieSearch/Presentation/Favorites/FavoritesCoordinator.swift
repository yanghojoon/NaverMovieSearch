import UIKit

final class FavoritesCoordinator: CoordinatorDescribing {
    
    // MARK: - Initializers
    var childCoordinators: [CoordinatorDescribing] = []
    var navigationController: UINavigationController?
    weak var delegate: ChildCoordinatorDelegate!
    
    // MARK: - Initializers
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
    
    func start(with favoriteMovies: [Movie]) {
        let favoritesViewModel = FavoritesViewModel(favoriteMovies: favoriteMovies)
        let favoritesViewController = FavoritesViewController(
            viewModel: favoritesViewModel,
            coordinator: self
        )
        
        navigationController?.pushViewController(favoritesViewController, animated: false)
    }
    
    func finish() {
        delegate.removeFromChildCoordinators(coordinator: self)
    }
    
    func showDetailPage(with information: (CellItem, IndexPath)) {
        let detailCoordinator = DetailCoordinator(navigationController: navigationController)
        childCoordinators.append(detailCoordinator)
        detailCoordinator.delegate = self
        
        detailCoordinator.start(with: information, delegatee: nil)
    }
    
}

// MARK: - DetailCoordinator Delegate
extension FavoritesCoordinator: ChildCoordinatorDelegate {
    
    func removeFromChildCoordinators(coordinator: CoordinatorDescribing) {
        let updatedChildCoordinators = childCoordinators.filter { $0 !== coordinator }
        childCoordinators = updatedChildCoordinators
    }
    
}
