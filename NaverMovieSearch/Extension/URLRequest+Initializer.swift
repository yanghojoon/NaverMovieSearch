import Foundation

extension URLRequest {
    
    // MARK: - Initializers
    init?(api: APIProtocol) {
        // 중요하지 않은(서버비가 추가로 들지 않는) ID와 Secret이지만 이를 비워놓고 따로 전달하는 것이 좋다.
        let clientID = "{개발자에게 요청}"
        let clientSecret = "{개발자에게 요청}"
        
        guard let url = api.url else {
            return nil
        }
        
        self.init(url: url)
        self.httpMethod = "\(api.method)"
        self.setValue(clientID, forHTTPHeaderField: "X-Naver-Client-Id")
        self.setValue(clientSecret, forHTTPHeaderField: "X-Naver-Client-Secret")
    }
    
}
