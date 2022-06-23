import Foundation
import RxSwift

protocol MovieSearchViewModelDelegate: AnyObject {
    
    func stopLoadingActivityIndicator()
    func showNoResultAlert()
    
}

final class MovieSearchViewModel {
    
    // MARK: - Nested Types
    struct Input {
        
        let textFieldDidReturn: Observable<String>
        let favoriteMovie: Observable<(Movie, Bool)>
        let selectedItem: Observable<CellItem>
        let selectedIndexPath: Observable<IndexPath>
        let favoriteButtonDidTap: Observable<Void>
        let collectionViewDidScroll: Observable<IndexPath>
        
    }
    
    struct Output {
        
        let movieList: Observable<[MovieSection]>
        
    }
    
    // MARK: - Properties
    weak var delegate: MovieSearchViewModelDelegate!
    private let collectionViewDataSources = BehaviorSubject<[MovieSection]>(value: []) // drive를 사용할 수 있지 않을까?
    private let coordinator: SearchCoordinator?
    private let disposeBag = DisposeBag()
    private let searchCount = 20
    private var searchStart = 1
    private var favoriteMovies: [Movie] = []
    private var searchKeyword = ""
    
    // MARK: - Initializers
    init(coordinator: SearchCoordinator) {
        self.coordinator = coordinator
    }
    
    // MARK: - Methods
    func transform(_ input: Input) -> Output {
        let movieList = configureMovieList(with: input.textFieldDidReturn)
        let output = Output(movieList: movieList)
        
        configureFavoriteMovies(with: input.favoriteMovie)
        configureSelectedCellDetailWith(item: input.selectedItem, indexPath: input.selectedIndexPath)
        configureFavoriteMovieList(with: input.favoriteButtonDidTap)
        addNewItems(at: input.collectionViewDidScroll)
        
        return output
    }
    
    private func configureMovieList(with inputObserver: Observable<String>) -> Observable<[MovieSection]> {
        inputObserver
            .withUnretained(self)
            .flatMap { (self, searchKeyword) -> Observable<[MovieSection]> in
                self.searchStart = 1
                
                let sections = self.fetchMovieData(from: searchKeyword, start: self.searchStart)
                    .flatMap { searchResult -> Observable<[MovieSection]> in
                        if searchResult.items.count == .zero {
                            DispatchQueue.main.async {
                                self.delegate.showNoResultAlert()
                            }
                        } else {
                            let cellItems = self.createCellItem(from: searchResult.items)
                            let sections = [
                                MovieSection(header: "영화목록", items: cellItems)
                            ]
                            self.collectionViewDataSources.onNext(sections)
                        }
                        
                        DispatchQueue.main.async {
                            self.delegate.stopLoadingActivityIndicator()
                        }
                    
                    return self.collectionViewDataSources.asObservable()
                }
                
                return sections
            }
    }
    
    private func fetchMovieData(from keyword: String, start: Int) -> Observable<SearchResult> {
        searchKeyword = keyword
        let networkProvider = NetworkProvider()
        let searchResult = networkProvider.fetchData(
            api: NaverMovieAPI(queryTerm: keyword, start: start),
            decodingType: SearchResult.self
        )
        
        return searchResult
    }
    
    private func createCellItem(from movie: [Movie]) -> [CellItem] {
        var cellItems = [CellItem]()
        
        movie.forEach { movie in
            if favoriteMovies.contains(movie) {
                let cellItem = CellItem(movie: movie, isSelected: true)
                cellItems.append(cellItem)
            } else {
                let cellItem = CellItem(movie: movie, isSelected: false)
                cellItems.append(cellItem)
            }
        }
        
        return cellItems
    }
    
    private func configureFavoriteMovies(with inputObserver: Observable<(Movie, Bool)>) {
        inputObserver
            .withUnretained(self)
            .subscribe(onNext: { (self, selectedCellInfo) in
                let (movie, isSelected) = selectedCellInfo
                if isSelected {
                    self.favoriteMovies.append(movie)
                } else {
                    guard let index = self.favoriteMovies.firstIndex(of: movie) else { return }
                    _ = self.favoriteMovies.remove(at: index)
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func configureSelectedCellDetailWith(item: Observable<CellItem>, indexPath: Observable<IndexPath>) {
        Observable.zip(item, indexPath)
            .withUnretained(self)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { (self, cellInformation) in
                self.coordinator?.showDetailPage(with: cellInformation)
            })
            .disposed(by: disposeBag)
    }
    
    private func configureFavoriteMovieList(with inputObserver: Observable<Void>) {
        inputObserver
            .withUnretained(self)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { _ in
                self.coordinator?.showFavoritesPage(with: self.favoriteMovies)
            })
            .disposed(by: disposeBag)
    }
    
    private func configureNewItems(at indexPath: Observable<IndexPath>) -> Observable<[CellItem]> {
        return indexPath
            .withUnretained(self)
            .filter { (self, indexPath) in
                indexPath.row + 3 == self.searchStart + self.searchCount - 1
            }
            .flatMap { (self, _) -> Observable<[CellItem]> in
                self.searchStart += self.searchCount
                let newSearchResult = self.fetchMovieData(from: self.searchKeyword, start: self.searchStart)
                let newCellItems = newSearchResult.map { self.createCellItem(from: $0.items) }
                
                return newCellItems
            }
    }
    
    private func addNewItems(at indexPath: Observable<IndexPath>) {
        self.configureNewItems(at: indexPath)
            .withUnretained(self)
            .subscribe(onNext: { (self, cellItem) in
                guard let originCellItems = try? self.collectionViewDataSources.value().first?.items else { return }
                let sections = [
                    MovieSection(header: "영화목록", items: originCellItems + cellItem)
                ]
                self.collectionViewDataSources.onNext(sections)
            })
            .disposed(by: disposeBag)
    }
    
}
