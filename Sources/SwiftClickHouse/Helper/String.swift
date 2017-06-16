import Foundation

extension String {
    func match(pattern: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let nsString = NSString(string: self);
            var str = [String]();
            if let match = regex.firstMatch(in : self, options: [], range: NSMakeRange(0, self.utf16.count)) {
                for i in 1..<match.numberOfRanges {
#if os(Linux)
                    str.append(nsString.substring(with: match.range(at: i)));
#else
                    str.append(nsString.substring(with: match.rangeAt(i)));
#endif

                }
            }
            return str;
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}
