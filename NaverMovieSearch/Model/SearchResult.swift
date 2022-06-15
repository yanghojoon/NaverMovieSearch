import Foundation

struct SearchResult: Decodable {
    
    let items: [Movie]
    
}

struct Movie: Decodable, Equatable {
    
    let title: String
    let link: String
    let image: String
    let director: String
    let actor: String
    let userRating: String
    
}
