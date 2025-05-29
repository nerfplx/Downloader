import Foundation

class TimeConverter {
    static func timeStringToSeconds(_ timeString: String) -> Double? {
        let trimmed = timeString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        
        let parts = trimmed.split(separator: ":").reversed()
        guard parts.count <= 3 else { return nil }
        
        var total: Double = 0
        for (index, part) in parts.enumerated() {
            guard let value = Double(part), value >= 0 else { return nil }
            
            if index < 2 && value >= 60 { return nil }
            
            total += value * pow(60, Double(index))
        }
        
        return total
    }
    
    static func secondsToTimeString(_ seconds: Double) -> String {
        let hours = Int(seconds) / 3600
        let minutes = Int(seconds) % 3600 / 60
        let secs = Int(seconds) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%02d:%02d", minutes, secs)
        }
    }
}
