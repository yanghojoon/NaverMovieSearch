import Foundation

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
