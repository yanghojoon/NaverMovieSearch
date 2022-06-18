import RxSwift
import UIKit
import WebKit

protocol MovieDetailViewControllerDelegate: AnyObject {
    
    func starButtonDidTap(at indexPath: IndexPath, isSelected: Bool)
    
}

class MovieDetailViewController: UIViewController {
    
    // MARK: - Properties
    weak var delegate: MovieDetailViewControllerDelegate!
    private let informationCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewLayout()
    )
    private let detailWebView = WKWebView()
    private let disposeBag = DisposeBag()
    private var viewModel: MovieDetailViewModel!
    private var coordinator: DetailCoordinator!
    private var selectedIndexPath: IndexPath!
    
    // MARK: - Initializers
    convenience init(viewModel: MovieDetailViewModel, selectedIndexPath: IndexPath, coordinator: DetailCoordinator) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
        self.selectedIndexPath = selectedIndexPath
        self.coordinator = coordinator
    }
    
    // MARK: - Deinitializers
    deinit {
        coordinator.finish()
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        bind()
        configureUI()
        configureCollectionView()
    }
    
    // MARK: - Methods
    private func configureNavigationBar() {
        let backButton: UIButton = {
            let button = UIButton()
            button.setTitle("", for: .normal)
            return button
        }()
        navigationItem.backBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    private func configureUI() {
        view.addSubview(informationCollectionView)
        view.addSubview(detailWebView)
        detailWebView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            informationCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            informationCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            informationCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            informationCollectionView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.15),
            
            detailWebView.topAnchor.constraint(equalTo: informationCollectionView.bottomAnchor),
            detailWebView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            detailWebView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            detailWebView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    private func configureCollectionView() {
        informationCollectionView.translatesAutoresizingMaskIntoConstraints = false
        informationCollectionView.register(cellClass: MovieCell.self)
        informationCollectionView.collectionViewLayout = createCollectionViewLayout()
    }
    
    private func createCollectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { _, _ -> NSCollectionLayoutSection in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitem: item,
                count: 1
            )
            
            let section = NSCollectionLayoutSection(group: group)
            
            return section
        }
        
        return layout
    }

}

// MARK: - Binding Methods
extension MovieDetailViewController {
    
    private func bind() {
        let output = viewModel.transform()
        
        configureMovieDetailContent(with: output.movieInformation)
    }
    
    private func configureMovieDetailContent(with movieInformation: Observable<[CellItem]>) {
        movieInformation
            .bind(to: informationCollectionView.rx.items(
                cellIdentifier: String(describing: MovieCell.self),
                cellType: MovieCell.self
            )) { [weak self] _, item, cell in
                cell.delegate = self
                cell.apply(item: item)
                cell.hideTitleLabel()
                self?.loadWebContent(url: item.movie.link)
                self?.navigationItem.title = item.movie.title.replaceWord
            }
            .disposed(by: disposeBag)
    }
    
    private func loadWebContent(url: String) {
        if let url = URL(string: url) {
            let urlRequest = URLRequest(url: url)
            detailWebView.load(urlRequest)
        }
    }
    
}

// MARK: - Cell Delegate
extension MovieDetailViewController: MovieListCellDelegate {
    
    func starButtonDidTap(at cell: MovieCell, isSelected: Bool) {
        if delegate != nil {
            delegate.starButtonDidTap(at: selectedIndexPath, isSelected: isSelected)
        }
    }
    
}

// MARK: - NameSpaces
extension MovieDetailViewController {
    
    private enum Design {
        
        static let summaryStackViewHorizontalInset: CGFloat = 10
        static let summaryStackViewVerticalInset: CGFloat = 15
        static let summaryStackViewSpacing: CGFloat = 10
        
        static let descriptionContentFont: UIFont = .preferredFont(forTextStyle: .body)
    }
    
}
