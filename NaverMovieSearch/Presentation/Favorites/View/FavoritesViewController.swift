import RxCocoa
import RxDataSources
import RxSwift
import UIKit

class FavoritesViewController: UIViewController {
    
    // MARK: - Properties
    private let listCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewLayout()
    )
    private let disposeBag = DisposeBag()
    private let cancelledIndexPath = PublishSubject<IndexPath>()
    private var viewModel: FavoritesViewModel!
    private var coordinator: FavoritesCoordinator!
    private var dataSource: MovieSectionDataSource!
    
    typealias MovieSectionDataSource = RxCollectionViewSectionedReloadDataSource<MovieSection>
    
    // MARK: - Initializers
    convenience init(viewModel: FavoritesViewModel, coordinator: FavoritesCoordinator) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
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
        configureUI()
        configureCollectionView()
        bind()
    }
    
    // MARK: - Methods
    private func configureNavigationBar() {
        navigationItem.title = Design.navigationTitle
    }
    
    private func configureUI() {
        view.backgroundColor = Design.backgroundColor
        view.addSubview(listCollectionView)
        
        NSLayoutConstraint.activate([
            listCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            listCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            listCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            listCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10)
        ])
    }
    
    private func configureCollectionView() {
        listCollectionView.translatesAutoresizingMaskIntoConstraints = false
        listCollectionView.register(cellClass: MovieCell.self)
        listCollectionView.collectionViewLayout = createCollectionViewLayout()
        listCollectionView.backgroundColor = Design.backgroundColor
        dataSource = createCollectionViewDataSource()
    }
    
    private func createCollectionViewDataSource() -> MovieSectionDataSource {
        let dataSource = MovieSectionDataSource { _, collectionView, indexPath, item -> UICollectionViewCell in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: MovieCell.self),
                for: indexPath
            ) as? MovieCell else {
                return UICollectionViewCell()
            }
            cell.delegate = self
            cell.apply(item: item)
            
            return cell
        }
        
        return dataSource
    }
    
    private func createCollectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { _, _ -> NSCollectionLayoutSection in
            let screenHeight = UIScreen.main.bounds.height
            
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0.5, leading: 0, bottom: 0.5, trailing: 0)
            
            var groupSize: NSCollectionLayoutSize
            if screenHeight < Design.deviceHeightStandard {
                groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(0.2)
                )
            } else {
                groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(0.15)
                )
            }
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
extension FavoritesViewController {
    
    private func bind() {
        let input = FavoritesViewModel.Input(cancelledIndexPath: cancelledIndexPath.asObservable())
        let output = viewModel.transform(input)
        
        configureListCollectionView(with: output.sections)
    }
    
    private func configureListCollectionView(with sections: Observable<[MovieSection]>) {
        sections
            .bind(to: listCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
}

// MARK: - Cell Delegate
extension FavoritesViewController: MovieListCellDelegate {
    
    func starButtonDidTap(at cell: MovieCell, isSelected: Bool) {
        guard let indexPath = listCollectionView.indexPath(for: cell) else { return }
        cancelledIndexPath.onNext(indexPath)
    }
    
}

// MARK: - NameSpaces
extension FavoritesViewController {
    
    enum Design {
        
        static let navigationTitle = "즐겨찾기 목록"
        static let backgroundColor: UIColor = .systemGray6
        static let deviceHeightStandard: CGFloat = 750
        
    }
    
}
