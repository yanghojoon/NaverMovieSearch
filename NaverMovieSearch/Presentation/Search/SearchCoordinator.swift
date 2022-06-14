import UIKit

final class SearchCoordinator: CoordinatorDescribing {
    
    // MARK: - Properties
    var childCoordinators: [CoordinatorDescribing] = []
    var navigationController: UINavigationController?
    
    // MARK: - Initializers
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
    
    // MARK: - Methos
    func start() {
        let movieSearchViewController = MoviewSearchViewController()
        
        navigationController?.pushViewController(movieSearchViewController, animated: true)
    }
    
}
