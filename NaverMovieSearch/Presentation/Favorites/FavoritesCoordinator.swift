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
    
}
