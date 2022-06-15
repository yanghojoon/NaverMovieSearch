import Foundation
import UIKit

final class AppCoordinator: CoordinatorDescribing {
    
    // MARK: - Properties
    var childCoordinators: [CoordinatorDescribing] = []
    var navigationController: UINavigationController?
    
    // MARK: - Initializers
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
    
    // MARK: - Methods
    func start() {
        showMovieSearchPage()
    }
    
}

extension AppCoordinator {
    
    private func showMovieSearchPage() {
        guard let navigationController = navigationController else { return }
        let searchCoordinator = SearchCoordinator(navigationController: navigationController)
        childCoordinators.append(searchCoordinator)
        
        searchCoordinator.start()
    }
    
}
