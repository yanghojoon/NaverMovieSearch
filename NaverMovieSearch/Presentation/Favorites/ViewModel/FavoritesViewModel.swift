import Foundation
import RxSwift

final class FavoritesViewModel {
    struct Input {
        
        let cancelledIndexPath: Observable<IndexPath>
        let selectedItem: Observable<CellItem>
        let selectedIndexPath: Observable<IndexPath>
        
    }
    
    struct Output {
        
        let sections: Observable<[MovieSection]>
        let selectedInformation: Observable<(CellItem, IndexPath)>
        
    }
    
    // MARK: - Properties
    private let sectionsSubject = BehaviorSubject<[MovieSection]>(value: [])
    private let disposeBag = DisposeBag()
    private var favoriteMovies: [CellItem]
    
    // MARK: - Initializers
    init(favoriteMovies: [Movie]) {
        self.favoriteMovies = favoriteMovies.map { CellItem(movie: $0, isSelected: true) }
    }
    
    func transform(_ input: Input) -> Output {
        makeSections()
        let sections = configureSections()
        let selectedInformation = configureSelectedInformationWith(item: input.selectedItem, indexPath: input.selectedIndexPath)
        let output = Output(sections: sections, selectedInformation: selectedInformation)
        
        return output
    }
    
    private func configureSections() -> Observable<[MovieSection]> {
        return sectionsSubject.asObservable()
    }
    
    private func makeSections() {
        let sections = [
            MovieSection(header: "즐겨찾기 영화", items: favoriteMovies)
        ]
        
        sectionsSubject.onNext(sections)
    }
    
    private func configureSelectedInformationWith(
        item: Observable<CellItem>,
        indexPath: Observable<IndexPath>
    ) -> Observable<(CellItem, IndexPath)> {
        return Observable.zip(item, indexPath)
    }
    
}
