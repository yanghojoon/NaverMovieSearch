import Foundation
import RxDataSources

class CellItem: Equatable { // CoreData나 Realm같은 로컬 DB를 쓴다면 굳이 나눌 필요가 있을까?
    
    let movie: Movie
    var isSelected: Bool
    
    init(movie: Movie, isSelected: Bool) {
        self.movie = movie
        self.isSelected = isSelected
    }
    
    static func == (lhs: CellItem, rhs: CellItem) -> Bool {
        return lhs.movie == rhs.movie && lhs.isSelected == rhs.isSelected
    }
    
}

struct MovieSection {
    
    var header: String
    var items: [CellItem]
    
}

extension MovieSection: SectionModelType {
    
    init(original: MovieSection, items: [CellItem]) {
        self = original
        self.items = items
    }
    
}
