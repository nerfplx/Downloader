import Combine
import UIKit

@MainActor
class VideoClipViewModel: ObservableObject {
    @Published var videoURL = ""
    @Published var startTime = ""
    @Published var endTime = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var videoData: Data?
    @Published var tempVideoURL: URL?
    
    private let videoService: VideoClipServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(videoService: VideoClipServiceProtocol = VideoClipService()) {
        self.videoService = videoService
        setupValidation()
    }
    
    private func setupValidation() {
        Publishers.CombineLatest3($videoURL, $startTime, $endTime)
            .dropFirst()
            .sink { [weak self] _, _, _ in
                self?.errorMessage = nil
            }
            .store(in: &cancellables)
    }
    
    var canDownload: Bool {
        !isLoading && !videoURL.isEmpty && !startTime.isEmpty && !endTime.isEmpty
    }
    
    func downloadClip() {
        Task {
            await performDownload()
        }
    }
    
    private func performDownload() async {
        isLoading = true
        errorMessage = nil
        videoData = nil
        tempVideoURL = nil
        
        defer { isLoading = false }
        
        do {
            let request = try createRequest()
            let data = try await videoService.downloadClip(request: request)
            
            videoData = data
            tempVideoURL = try VideoFileManager.saveVideoToTempFile(data)
            
        } catch let error as VideoClipError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Неизвестная ошибка: \(error.localizedDescription)"
        }
    }
    
    private func createRequest() throws -> VideoClipRequest {
        guard !videoURL.isEmpty, !startTime.isEmpty, !endTime.isEmpty else {
            throw VideoClipError.emptyFields
        }
        
        guard let startSeconds = TimeConverter.timeStringToSeconds(startTime) else {
            throw VideoClipError.invalidTimeFormat
        }
        
        guard let endSeconds = TimeConverter.timeStringToSeconds(endTime) else {
            throw VideoClipError.invalidTimeFormat
        }
        
        guard startSeconds < endSeconds else {
            throw VideoClipError.invalidTimeFormat
        }
        
        guard URL(string: videoURL) != nil else {
            throw VideoClipError.invalidURL
        }
        
        return VideoClipRequest(url: videoURL, start: startSeconds, end: endSeconds)
    }
    
    func saveVideo() {
        guard let data = videoData else { return }
        
        do {
            let tempURL = try VideoFileManager.saveVideoToTempFile(data, filename: "saved_clip.mp4")
            shareFile(url: tempURL)
        } catch {
            errorMessage = "Ошибка сохранения: \(error.localizedDescription)"
        }
    }
    
    private func shareFile(url: URL) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            errorMessage = "Не удалось найти контроллер для отображения"
            return
        }
        
        let activityVC = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )
        
        if let popoverController = activityVC.popoverPresentationController {
            popoverController.sourceView = window
            popoverController.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        rootViewController.present(activityVC, animated: true)
    }
    
    func clearData() {
        videoData = nil
        tempVideoURL = nil
        errorMessage = nil
    }
}
