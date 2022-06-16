import Foundation
import RxSwift

final class MovieDetailViewModel {
    
    // MARK: - NestedType
    struct Output {
        
        let movieInformation: Observable<[CellItem]>
        
    }
    
    // MARK: - Properties
    private let movie: CellItem
    private let disposeBag = DisposeBag()
    
    // MARK: - Initializers
    init(movie: CellItem) {
        self.movie = movie
    }
    
    func transform() -> Output {
        let movieInformation = configureMovieInformation()
        let ouput = Output(movieInformation: movieInformation)
        
        return ouput
    }
    
    private func configureMovieInformation() -> Observable<[CellItem]> {
        return Observable.just([movie])
    }
    
}
