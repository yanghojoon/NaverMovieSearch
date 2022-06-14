import RxCocoa
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
    private var viewModel: MovieSearchViewModel?
    private let listCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    private let textFieldDidReturn = PublishSubject<String>()
    private let disposeBag = DisposeBag()
    
    // MARK: - Initializers
    convenience init(viewModel: MovieSearchViewModel) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
        configureTextField()
        configureCollectionView()
        bind()
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
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
    }
    
    private func configureUI() {
        view.backgroundColor = .systemGray6
        view.addSubview(searchTextField)
        view.addSubview(listCollectionView)
        
        NSLayoutConstraint.activate([
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
        listCollectionView.register(cellClass: MovieListCell.self)
        listCollectionView.collectionViewLayout = createCollectionViewLayout()
        listCollectionView.backgroundColor = .systemGray6
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
            if screenHeight < 750 {
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
        let input = MovieSearchViewModel.Input(textFieldDidReturn: textFieldDidReturn.asObservable())
        guard let output = viewModel?.transform(input) else { return }
        
        configureListCollectionView(with: output.movieList)
    }
    
    private func configureListCollectionView(with movieList: Observable<[Movie]>) {
        movieList
            .bind(to: listCollectionView.rx.items(
                cellIdentifier: String(describing: MovieListCell.self),
                cellType: MovieListCell.self
            )) { _, item, cell in
                cell.apply(
                    imageURL: item.image,
                    title: item.title,
                    director: item.director,
                    actors: item.actor,
                    userRating: item.userRating
                )
            }
            .disposed(by: disposeBag)
    }
    
}

// MARK: - TexfField Delegate
extension MovieSearchViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let searchKeyword = textField.text else { return false }
        
        view.endEditing(true)
        listCollectionView.setContentOffset(CGPoint.zero, animated: true)
        textFieldDidReturn.onNext(searchKeyword)
        return true
    }
    
}

// MARK: - Namespaces
extension MovieSearchViewController {
    
    private enum Design {
        
        static let searchTextFieldPlaceHolder = "영화 제목을 검색해보세요!"
        static let titleText = "네이버 영화 검색"
        
    }
    
}
