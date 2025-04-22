protocol RocketService {
    func fetch(by id: String) async throws -> Rocket
}

struct RocketServiceImpl: RocketService {
    private let apiClient: APIClient
    private let cache: CacheService

    init(apiClient: APIClient, cache: CacheService) {
        self.apiClient = apiClient
        self.cache = cache
    }

    func fetch(by id: String) async throws -> Rocket {
        do {
            let rocket: Rocket = try await apiClient.fetch(.rockets(id: id))
            try cache.save(rocket, to: .rocket(id: id))
            return rocket
        } catch {
            if let cached: Rocket = try cache.load(from: .rocket(id: id)) {
                return cached
            } else {
                throw error
            }
        }
    }
}
