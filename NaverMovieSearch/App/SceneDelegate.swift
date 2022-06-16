import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var appCoordinator: CoordinatorDescribing?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
   
        window = UIWindow(windowScene: windowScene)
        window?.makeKeyAndVisible()
        
        let navigationController = UINavigationController()
        navigationController.view.backgroundColor = .systemBackground
        window?.rootViewController = navigationController
        
        appCoordinator = AppCoordinator(navigationController: navigationController)
        guard let appCoordinator = appCoordinator as? AppCoordinator else { return }

        appCoordinator.start()
    }

}
