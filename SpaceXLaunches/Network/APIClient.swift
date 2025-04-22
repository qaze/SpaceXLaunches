import Foundation

protocol APIClient {
    func fetch<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}

struct APIClientImpl: APIClient {
    private let session: Session
    private let decoder: JSONDecoder
    private let requestBuilder: URLRequestBuilder

    init(session: Session, requestBuilder: URLRequestBuilder) {
        self.session = session
        self.decoder = JSONDecoder()
        self.requestBuilder = requestBuilder
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        self.decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            if let date = formatter.date(from: dateString) {
                return date
            }
            
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid date format: \(dateString)"
            )
        }
    }

    func fetch<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let request = try requestBuilder.makeUrlRequest(for: endpoint)
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
                200..<300 ~= httpResponse.statusCode else {
            throw APIError.invalidResponse
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingFailed
        }
    }
}
