import Foundation

extension String {
    
    var replaceWord: String {
        var word = self
        if word.isEmpty {
            return "-"
        }
        
        if word.last == "|" {
            word.removeLast()
        }
        var result = word.replacingOccurrences(of: "<b>", with: "")
        result = result.replacingOccurrences(of: "</b>", with: "")
        result = result.replacingOccurrences(of: "|", with: ", ")
        result = result.replacingOccurrences(of: "&amp;", with: "")
        
        return result
    }
    
}
