import UIKit

final class MoviewSearchViewController: UIViewController {
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
    }
    
    // MARK: - Methods
    private func configureNavigationBar() {
        let titleLabel: UILabel = {
            let label = UILabel()
            label.text = "네이버 영화 검색"
            label.font = .preferredFont(forTextStyle: .title1)
            label.textAlignment = .left
            return label
        }()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
    }
    
}
