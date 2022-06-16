import UIKit

protocol CoordinatorDescribing: AnyObject {
    
    var childCoordinators: [CoordinatorDescribing] { get set }
    var navigationController: UINavigationController? { get set }
    
}
