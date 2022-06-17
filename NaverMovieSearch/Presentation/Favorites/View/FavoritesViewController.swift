import RxSwift
import UIKit

class FavoritesViewController: UIViewController {
    
    // MARK: - Properties
    private let listCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewLayout()
    )
    private let disposeBag = DisposeBag()
    private var viewModel: FavoritesViewModel!
    private var coordinator: FavoritesCoordinator!
    
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
        let input = FavoritesViewModel.Input()
        let output = viewModel.transform(input)
        
        configureListCollectionView(with: output.cellItems)
    }
    
    private func configureListCollectionView(with movieList: Observable<[CellItem]>) {
        movieList
            .bind(to: listCollectionView.rx.items) { collectionView, row, item in
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: String(describing: MovieCell.self),
                    for: IndexPath(row: row, section: .zero)) as? MovieCell
                else {
                    return UICollectionViewCell()
                }
                
                cell.apply(item: item)
                cell.delegate = self
                
                return cell
            }
            .disposed(by: disposeBag)
    }
    
}

// MARK: - Cell Delegate
extension FavoritesViewController: MovieListCellDelegate {
    
    func starButtonDidTap(at cell: MovieCell, isSelected: Bool) {
        
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
