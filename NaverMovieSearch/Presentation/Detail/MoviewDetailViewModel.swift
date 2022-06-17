import Foundation
import RxSwift

final class MovieDetailViewModel {
    
    // MARK: - NestedType
    struct Output {
        
        let movieInformation: Observable<[CellItem]>
        
    }
    
    // MARK: - Properties
    private let movie: CellItem
    
    // MARK: - Initializers
    init(movie: CellItem) {
        self.movie = movie
    }
    
    // MARK: - Methods
    func transform() -> Output {
        let movieInformation = configureMovieInformation()
        let output = Output(movieInformation: movieInformation)
        
        return output
    }
    
    private func configureMovieInformation() -> Observable<[CellItem]> {
        return Observable.just([movie])
    }
    
}
