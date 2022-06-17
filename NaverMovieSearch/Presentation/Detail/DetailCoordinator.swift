import UIKit

final class DetailCoordinator: CoordinatorDescribing {
    
    // MARK: - Properties
    var childCoordinators: [CoordinatorDescribing] = []
    var navigationController: UINavigationController?
    weak var delegate: ChildCoordinatorDelegate!
    
    // MARK: - Initializers
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
    
    // MARK: - Methods
    func start(
        with item: (movie: CellItem, indexPath: IndexPath),
        delegatee: MovieSearchViewController
    ) {
        let movieDetailViewModel = MovieDetailViewModel(movie: item.movie)
        let movieDetailViewController = MovieDetailViewController(
            viewModel: movieDetailViewModel,
            selectedIndexPath: item.indexPath,
            coordinator: self
        )
        movieDetailViewController.delegate = delegatee
        
        navigationController?.pushViewController(movieDetailViewController, animated: false)
    }
    
    func finish() {
        delegate.removeFromChildCoordinators(coordinator: self)
    }
    
}
