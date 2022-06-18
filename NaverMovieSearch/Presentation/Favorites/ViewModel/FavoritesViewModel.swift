import Foundation
import RxSwift

final class FavoritesViewModel {
    struct Input {
        let cancelledIndexPath: Observable<IndexPath>
    }
    
    struct Output {
        let sections: Observable<[MovieSection]>
    }
    
    // MARK: - Properties
    private var favoriteMovies: [CellItem]
    private let sectionsSubject = BehaviorSubject<[MovieSection]>(value: [])
    private let disposeBag = DisposeBag()
    
    // MARK: - Initializers
    init(favoriteMovies: [Movie]) {
        self.favoriteMovies = favoriteMovies.map { CellItem(movie: $0, isSelected: true) }
    }
    
    func transform(_ input: Input) -> Output {
        makeSections()
        let sections = configureSections()
        let output = Output(sections: sections)
        
        removeItem(with: input.cancelledIndexPath)
        
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
    
    private func removeItem(with indexPath: Observable<IndexPath>) {
        indexPath
            .withUnretained(self)
            .subscribe(onNext: { (self, indexPath) in
                guard var sections = try? self.sectionsSubject.value() else { return }
                var currentSection = sections[indexPath.section]
                currentSection.items.remove(at: indexPath.row)
                sections[indexPath.section] = currentSection
                self.favoriteMovies = currentSection.items
                print(self.favoriteMovies)
                
                self.sectionsSubject.onNext(sections)
            })
            .disposed(by: disposeBag)
    }
    
}
