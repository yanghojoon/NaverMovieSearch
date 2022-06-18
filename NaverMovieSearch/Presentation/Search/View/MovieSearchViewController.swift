import RxCocoa
import RxDataSources
import RxSwift
import UIKit

final class MovieSearchViewController: UIViewController {
    
    // MARK: - Properties
    private let searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = Design.searchTextFieldPlaceHolder
        textField.borderStyle = .roundedRect
        textField.returnKeyType = .search
        textField.clearButtonMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    private let listCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewLayout()
    )
    private let favoriteButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setImage(Design.favoriteButtonImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .systemYellow
        button.setTitle(Design.favoriteButtonTitle, for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.layer.cornerRadius = Design.favoriteButtonCornerRadius
        button.layer.borderWidth = Design.favoriteButtonBorderWidth
        button.layer.borderColor = Design.favoriteButtonBorderColor
        button.clipsToBounds = true
        button.widthAnchor.constraint(equalToConstant: button.intrinsicContentSize.width + 10).isActive = true
        button.heightAnchor.constraint(equalToConstant: button.intrinsicContentSize.height + 5).isActive = true
        return button
    }()
    private let loadingActivityIndicator = UIActivityIndicatorView()
    private let textFieldDidReturn = PublishSubject<String>()
    private let favoriteMovie = PublishSubject<(Movie, Bool)>()
    private let collectionViewDidScroll = PublishSubject<IndexPath>()
    private let disposeBag = DisposeBag()
    private var viewModel: MovieSearchViewModel?
    private var collectionViewDataSource: MovieSectionDataSource!

    typealias MovieSectionDataSource = RxCollectionViewSectionedReloadDataSource<MovieSection>
    
    // MARK: - Initializers
    convenience init(viewModel: MovieSearchViewModel) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel?.delegate = self
        configureNavigationBar()
        configureUI()
        configureTextField()
        configureCollectionView()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        listCollectionView.reloadData()
    }
    
    // MARK: - Methods
    private func configureNavigationBar() {
        let titleLabel: UILabel = {
            let label = UILabel()
            label.text = Design.titleText
            label.font = .preferredFont(forTextStyle: .title1)
            label.textAlignment = .left
            return label
        }()
        navigationItem.backButtonTitle = Design.backButtonTitle
        navigationController?.navigationBar.tintColor = Design.navigationBarTintColor
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: favoriteButton)
    }
    
    private func configureUI() {
        loadingActivityIndicator.translatesAutoresizingMaskIntoConstraints = false

        view.backgroundColor = .systemGray6
        view.addSubview(searchTextField)
        view.addSubview(listCollectionView)
        view.addSubview(loadingActivityIndicator)
        
        NSLayoutConstraint.activate([
            loadingActivityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingActivityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            searchTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 2),
            searchTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            searchTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            listCollectionView.widthAnchor.constraint(equalTo: searchTextField.widthAnchor),
            listCollectionView.centerXAnchor.constraint(equalTo: searchTextField.centerXAnchor),
            listCollectionView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor),
            listCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func configureTextField() {
        searchTextField.delegate = self
    }
    
    private func configureCollectionView() {
        listCollectionView.translatesAutoresizingMaskIntoConstraints = false
        listCollectionView.register(cellClass: MovieCell.self)
        listCollectionView.collectionViewLayout = createCollectionViewLayout()
        listCollectionView.backgroundColor = .systemGray6
        listCollectionView.delegate = self
        collectionViewDataSource = createCollectionViewDataSource()
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
extension MovieSearchViewController {
    
    private func bind() {
        let input = MovieSearchViewModel.Input(
            textFieldDidReturn: textFieldDidReturn.asObservable(),
            favoriteMovie: favoriteMovie.asObservable(),
            selectedItem: listCollectionView.rx.modelSelected(CellItem.self).asObservable(),
            selectedIndexPath: listCollectionView.rx.itemSelected.asObservable(),
            favoriteButtonDidTap: favoriteButton.rx.tap.asObservable(),
            collectionViewDidScroll: collectionViewDidScroll.asObservable()
        )
        guard let output = viewModel?.transform(input) else { return }
        
        configureListCollectionView(with: output.movieList)
    }
    
    private func configureListCollectionView(
        with movieList: Observable<[MovieSection]>
    ) {
        movieList
            .bind(to: listCollectionView.rx.items(dataSource: collectionViewDataSource))
            .disposed(by: disposeBag)
    }
    
}

// MARK: - MovieSearchViewModel Delegate
extension MovieSearchViewController: MovieSearchViewModelDelegate {
    
    func stopLoadingActivityIndicator() {
        loadingActivityIndicator.stopAnimating()
    }
    
}

// MARK: - StarButtonDidTap Delegate
extension MovieSearchViewController: MovieListCellDelegate, MovieDetailViewControllerDelegate {
    
    // MovieDetailViewController Delegate
    func starButtonDidTap(at indexPath: IndexPath, isSelected: Bool) {
        guard let selectedCell = listCollectionView.cellForItem(at: indexPath) as? MovieCell else { return }
        
        favoriteMovie.onNext((selectedCell.makeMovieItem(), isSelected))
    }
    
    // MovieListCell Delegate
    func starButtonDidTap(at cell: MovieCell, isSelected: Bool) {
        guard let indexPath = listCollectionView.indexPath(for: cell),
              let selectedCell = listCollectionView.cellForItem(at: indexPath) as? MovieCell else {
            return
        }
        
        favoriteMovie.onNext((selectedCell.makeMovieItem(), isSelected))
    }
    
}

// MARK: - TextField Delegate
extension MovieSearchViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let searchKeyword = textField.text else { return false }
        
        loadingActivityIndicator.startAnimating()
        view.endEditing(true)
        listCollectionView.setContentOffset(CGPoint.zero, animated: true)
        textFieldDidReturn.onNext(searchKeyword)
        
        return true
    }
    
}

// MARK: - CollectionView Delegate
extension MovieSearchViewController: UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        collectionViewDidScroll.onNext(indexPath)
    }

}
    
// MARK: - NameSpaces
extension MovieSearchViewController {
    
    private enum Design {
        
        static let searchTextFieldPlaceHolder = "영화 제목을 검색해보세요!"
        static let titleText = "네이버 영화 검색"
        
        static let favoriteButtonImage = UIImage(systemName: "star.fill")
        static let favoriteButtonTitle = "즐겨찾기"
        static let favoriteButtonCornerRadius: CGFloat = 5
        static let favoriteButtonBorderWidth: CGFloat = 1
        static let favoriteButtonBorderColor = UIColor.systemGray4.cgColor
        
        static let navigationBarTintColor: UIColor = .systemGray
        static let backButtonTitle = ""
        static let deviceHeightStandard: CGFloat = 750
        
    }
    
}
