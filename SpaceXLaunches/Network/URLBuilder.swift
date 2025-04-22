import Foundation

protocol URLRequestBuilder {
    func makeUrlRequest(for endpoint: Endpoint) throws -> URLRequest
}

struct URLRequestBuilderImpl: URLRequestBuilder {
    private let baseURL = "https://api.spacexdata.com"
    
    init() { }
    
    func makeUrlRequest(for endpoint: Endpoint) throws -> URLRequest {
        let path = buildPath(for: endpoint)
        guard let url = URL(string: "\(baseURL)\(path)") else {
            throw APIError.invalidURL
        }
        return URLRequest(url: url)
    }
    
    private func buildPath(for endpoint: Endpoint) -> String {
        switch endpoint {
        case .launches:
            return "/v4/launches"
        case let .rockets(id):
            return "/v4/rockets/\(id)"
        }
    }
}
