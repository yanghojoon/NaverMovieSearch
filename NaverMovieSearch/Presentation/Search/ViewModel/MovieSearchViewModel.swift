import Foundation
import RxSwift

final class MovieSearchViewModel {
    
    // MARK: - Nested Types
    struct Input {
        
        let textFieldDidReturn: Observable<String>
        
    }
    
    struct Output {
        
        let movieList: Observable<[Movie]>
        
    }
    
    // MARK: - Methods
    func transform(_ input: Input) -> Output {
        let movieList = configureMovieList(with: input.textFieldDidReturn)
        let ouput = Output(movieList: movieList)
        
        return ouput
    }
    
    private func configureMovieList(with inputObserver: Observable<String>) -> Observable<[Movie]> {
        inputObserver
            .withUnretained(self)
            .flatMap { (self, searchKeyword) -> Observable<[Movie]> in
                let movieList = self.fetchMovieData(from: searchKeyword).map { searchResult in
                    return searchResult.items
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
}
