import SwiftUI

struct VideoClipRequest: Codable {
    let url: String
    let start: Double
    let end: Double
}

