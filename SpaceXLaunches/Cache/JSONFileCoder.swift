import Foundation

protocol JSONFileCoder {
    func encode<T: Encodable>(_ value: T, to url: URL) throws
    func decode<T: Decodable>(_ type: T.Type, from url: URL) throws -> T
}

struct JSONFileCoderImpl: JSONFileCoder {
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    
    init(encoder: JSONEncoder = JSONEncoder(), decoder: JSONDecoder = JSONDecoder()) {
        self.encoder = encoder
        self.decoder = decoder
    }
    
    func encode<T: Encodable>(_ value: T, to url: URL) throws {
        let data = try encoder.encode(value)
        try data.write(to: url)
    }
    
    func decode<T: Decodable>(_ type: T.Type, from url: URL) throws -> T {
        let data = try Data(contentsOf: url)
        return try decoder.decode(T.self, from: data)
    }
}



