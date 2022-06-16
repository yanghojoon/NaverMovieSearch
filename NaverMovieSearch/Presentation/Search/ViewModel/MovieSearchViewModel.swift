import Foundation
import RxSwift

final class MovieSearchViewModel {
    
    // MARK: - Nested Types
    struct Input {
        
        let textFieldDidReturn: Observable<String>
        let favoriteMovie: Observable<(Movie, Bool)>
        let selectedItem: Observable<CellItem>
        let selectedIndexPath: Observable<IndexPath>
        
    }
    
    struct Output {
        
        let movieList: Observable<[CellItem]>
        
    }
    
    // MARK: - Properties
    private var favoriteMovies: [Movie] = []
    private let coordinator: SearchCoordinator?
    private let disposeBag = DisposeBag()
    
    // MARK: - Initializers
    init(coordinator: SearchCoordinator) {
        self.coordinator = coordinator
    }
    
    // MARK: - Methods
    func transform(_ input: Input) -> Output {
        let movieList = configureMovieList(with: input.textFieldDidReturn)
        let ouput = Output(movieList: movieList)
        
        configureFavoriteMovies(with: input.favoriteMovie)
        configureSelectedCellDetailWith(item: input.selectedItem, indexPath: input.selectedIndexPath)
        
        return ouput
    }
    
    private func configureMovieList(with inputObserver: Observable<String>) -> Observable<[CellItem]> {
        inputObserver
            .withUnretained(self)
            .flatMap { (self, searchKeyword) -> Observable<[CellItem]> in
                let movieList = self.fetchMovieData(from: searchKeyword).map { searchResult in
                    return  self.createCellItem(from: searchResult.items)
                }
                
                return movieList
            }
    }
    
    private func fetchMovieData(from keyword: String) -> Observable<SearchResult> {
        let networkProvider = NetworkProvider()
        let searchResult = networkProvider.fetchData(
            api: NaverMovieAPI(queryTerm: keyword),
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
    
}
