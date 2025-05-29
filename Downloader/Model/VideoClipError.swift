import SwiftUI

enum VideoClipError: LocalizedError {
    case invalidURL
    case invalidTimeFormat
    case emptyFields
    case networkError(String)
    case fileError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Некорректная ссылка на видео"
        case .invalidTimeFormat:
            return "Неверный формат времени. Используйте мм:сс или чч:мм:сс"
        case .emptyFields:
            return "Заполните все поля"
        case .networkError(let message):
            return "Ошибка сети: \(message)"
        case .fileError(let message):
            return "Ошибка файла: \(message)"
        }
    }
}
