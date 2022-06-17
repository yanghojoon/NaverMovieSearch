import Foundation
import RxSwift

final class FavoritesViewModel {
    struct Input {
        
    }
    
    struct Output {
        let cellItems: Observable<[CellItem]>
    }
    
    // MARK: - Properties
    private var favoriteMovies: [Movie]
    
    // MARK: - Initializers
    init(favoriteMovies: [Movie]) {
        self.favoriteMovies = favoriteMovies
    }
    
    func transform(_ input: Input) -> Output {
        let favoriteMovies = configureFavoriteMovies()
        let ouput = Output(cellItems: favoriteMovies)
        
        return ouput
    }
    
    private func configureFavoriteMovies() -> Observable<[CellItem]> {
        let cellItem = favoriteMovies.map { CellItem(movie: $0, isSelected: true) }
        return Observable.just(cellItem)
    }
    
}
