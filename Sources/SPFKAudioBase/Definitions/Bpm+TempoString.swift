// Copyright Ryan Francesconi. All Rights Reserved.

import Foundation

extension Bpm {
    /// Creates a `Bpm` by parsing a string that contains a recognizable tempo pattern.
    ///
    /// Recognized patterns (case-insensitive):
    /// - `Tempo: 120` / `Tempo 120`
    /// - `BPM 120` / `BPM120`
    /// - `120 BPM` / `120bpm`
    ///
    /// Returns `nil` if no pattern matches or the extracted value is not a valid tempo.
    public init?(tempoString: String) {
        guard let rawValue = Self.extractTempoValue(from: tempoString),
              let bpm = Bpm(rawValue) else { return nil }
        self = bpm
    }

    private static func extractTempoValue(from string: String) -> Double? {
        // "Tempo: 120", "Tempo 120", "BPM 120", "BPM120"
        if let value = firstCaptureGroup(in: string, pattern: "(?:tempo[: ]+|bpm[ ]*)(\\d+(?:\\.\\d+)?)") {
            return Double(value)
        }

        // "120 BPM", "120bpm"
        if let value = firstCaptureGroup(in: string, pattern: "(\\d+(?:\\.\\d+)?)[ ]*bpm") {
            return Double(value)
        }

        return nil
    }

    /// Returns the first capture group of the first match, or nil. Uses NSRegularExpression so the
    /// parsing runs on iOS 15 (the Swift Regex literals it replaced require iOS 16).
    private static func firstCaptureGroup(in string: String, pattern: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
            return nil
        }
        let fullRange = NSRange(string.startIndex..., in: string)
        guard let match = regex.firstMatch(in: string, options: [], range: fullRange),
              match.numberOfRanges > 1,
              let captureRange = Range(match.range(at: 1), in: string) else {
            return nil
        }
        return String(string[captureRange])
    }
}
