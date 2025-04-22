import Foundation

struct Launch: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let dateUTC: Date
    let rocket: String
    let details: String?
    let links: Links?

    struct Links: Codable, Equatable {
        let webcast: URL?
        let patch: Patch?

        struct Patch: Codable, Equatable {
            let small: URL?
            let large: URL?
        }
    }

    enum CodingKeys: String, CodingKey {
        case id, name, rocket, details, links
        case dateUTC = "date_utc"
    }
}
