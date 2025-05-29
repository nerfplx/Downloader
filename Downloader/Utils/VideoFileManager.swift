import Foundation

class VideoFileManager {
    static func saveVideoToTempFile(_ data: Data, filename: String = "video_clip.mp4") throws -> URL {
        let tempURL = Foundation.FileManager.default.temporaryDirectory
            .appendingPathComponent(filename)
        
        try data.write(to: tempURL)
        return tempURL
    }
}
