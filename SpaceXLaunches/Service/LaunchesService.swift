protocol LaunchService {
    func fetchAll() async throws -> [Launch]
}

struct LaunchesServiceImpl: LaunchService {
    private let apiClient: APIClient
    private let cache: CacheService

    init(apiClient: APIClient, cache: CacheService) {
        self.apiClient = apiClient
        self.cache = cache
    }

    func fetchAll() async throws -> [Launch] {
        do {
            let rockets: [Launch] = try await apiClient.fetch(.launches)
            try cache.save(rockets, to: .launches)
            return rockets
        } catch {
            if let cached: [Launch] = try cache.load(from: .launches) {
                return cached
            } else {
                throw error
            }
        }
    }
}
