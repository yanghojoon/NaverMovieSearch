import Foundation

struct NaverMovieAPI: APIProtocol {
    
    // MARK: - Properties
    var url: URL?
    var method: HttpMethod = .get
    
    // MARK: - Initializers
    init(queryTerm: String, displayCount: Int = 20, start: Int = 1) {
        let baseURL = "https://openapi.naver.com/v1/search/movie.json"
        guard let queryData = queryTerm.data(using: .utf8) else { return }
        var urlComponents = URLComponents(string: "\(baseURL)")
        let queryItem = [
            URLQueryItem(name: "query", value: "\(queryData)"),
            URLQueryItem(name: "display", value: "\(displayCount)"),
            URLQueryItem(name: "start", value: "\(start)")
        ]
        urlComponents?.queryItems = queryItem
        
        self.url = urlComponents?.url
    }
    
}
