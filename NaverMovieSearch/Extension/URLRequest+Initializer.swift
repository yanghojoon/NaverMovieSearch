import Foundation

extension URLRequest {
    
    // MARK: - Initializers
    init?(api: APIProtocol) {
        let clientID = "Ojuz6q7nOZjRR8Nd4_XV"
        let clientSecret = "cnDaOmXUF2"
        
        guard let url = api.url else {
            return nil
        }
        
        self.init(url: url)
        self.httpMethod = "\(api.method)"
        self.setValue(clientID, forHTTPHeaderField: "X-Naver-Client-Id")
        self.setValue(clientSecret, forHTTPHeaderField: "X-Naver-Client-Secret")
    }
    
}
