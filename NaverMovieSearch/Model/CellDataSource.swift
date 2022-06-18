import Foundation
import RxDataSources

class CellItem: Equatable {
    
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
