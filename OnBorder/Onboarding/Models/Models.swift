import Foundation

struct Screen: Codable {
    let id: Int
    let name: String
    let content: ScreenContent
}

struct ScreenContent: Codable {
    let time: Int
    let blocks: [Block]
    let version: String
}

enum BlockType: String, Codable {
    case image, header, paragraph, list, button
}

struct Block: Codable, Identifiable {
    let id: String
    let type: BlockType
    let data: BlockData
}

enum BlockData: Codable {
    case image(ImageData)
    case header(HeaderData)
    case paragraph(ParagraphData)
    case list(ListData)
    case button(ButtonData)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let image = try? container.decode(ImageData.self) {
            self = .image(image)
        } else if let header = try? container.decode(HeaderData.self) {
            self = .header(header)
        } else if let button = try? container.decode(ButtonData.self) {
            self = .button(button)
        } else if let paragraph = try? container.decode(ParagraphData.self) {
            self = .paragraph(paragraph)
        } else if let list = try? container.decode(ListData.self) {
            self = .list(list)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid block data")
        }
    }
}

struct ImageData: Codable {
    let url: String
    let caption: String
    let withBorder: Bool
    let withBackground: Bool
    let stretched: Bool
}

struct HeaderData: Codable {
    let text: String
    let level: Int
}

struct ParagraphData: Codable {
    let text: String
}

struct ListData: Codable {
    let style: String
    let items: [String]
}

struct ButtonData: Codable {
    let link: String
    let text: String
}
