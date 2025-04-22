import Foundation

protocol CacheService {
    func save<T: Encodable>(_ data: T, to path: CachePath) throws
    func load<T: Decodable>(from path: CachePath) throws -> T
}

struct CacheServiceImpl: CacheService {
    private let jsonFileCoder: JSONFileCoder
    private let cachePathBuilder: CachePathBuilder
    
    init(
        cachePathBuilder: CachePathBuilder,
        jsonFileCoder: JSONFileCoder
    ) {
        self.cachePathBuilder = cachePathBuilder
        self.jsonFileCoder = jsonFileCoder
    }

    func save<T: Encodable>(_ data: T, to path: CachePath) throws {
        let url = cachePathBuilder.makeFileURL(for: path)
        try jsonFileCoder.encode(data, to: url)
    }

    func load<T: Decodable>(from path: CachePath) throws -> T {
        let url = cachePathBuilder.makeFileURL(for: path)
        return try jsonFileCoder.decode(T.self, from: url)
    }
}
