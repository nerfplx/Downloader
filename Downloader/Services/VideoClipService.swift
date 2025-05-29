import SwiftUI

protocol VideoClipServiceProtocol {
    func downloadClip(request: VideoClipRequest) async throws -> Data
}

class VideoClipService: VideoClipServiceProtocol {
    private let baseURL = "http://localhost:8000"
    private let session = URLSession.shared
    
    func downloadClip(request: VideoClipRequest) async throws -> Data {
        guard let url = URL(string: "\(baseURL)/clip") else {
            throw VideoClipError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.timeoutInterval = 60.0
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            throw VideoClipError.networkError("Ошибка кодирования запроса")
        }
        
        do {
            let (data, response) = try await session.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw VideoClipError.networkError("Неверный формат ответа")
            }
            
            guard 200...299 ~= httpResponse.statusCode else {
                throw VideoClipError.networkError("HTTP \(httpResponse.statusCode)")
            }
            
            guard !data.isEmpty else {
                throw VideoClipError.networkError("Пустой ответ от сервера")
            }
            
            return data
        } catch let error as VideoClipError {
            throw error
        } catch {
            throw VideoClipError.networkError(error.localizedDescription)
        }
    }
}
