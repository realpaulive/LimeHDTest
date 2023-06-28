import Foundation

// MARK: - LimeResponce
struct LimeResponse: Codable {
    let channels: [Channel]
    let valid: Int
    let ckey: String
}

// MARK: - Channel
struct Channel: Codable {
    let id: Int
    let nameRu: String
    let image: String
    let current: Current
    let url: String

    enum CodingKeys: String, CodingKey {
        case id
        case nameRu = "name_ru"
        case image
        case current
        case url
    }
}

// MARK: - Current
struct Current: Codable {
    let title: String
}
