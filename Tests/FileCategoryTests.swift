import Foundation
import Testing
@testable import PasteMemo

@Suite("File category recognition")
struct FileCategoryTests {
    @Test @MainActor
    func foldersAndPackagesAreNotConfusedWithExtensions() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }
        let plain = root.appendingPathComponent("folder")
        let dotted = root.appendingPathComponent("photos.png")
        let application = root.appendingPathComponent("Example.app")
        for url in [plain, dotted, application] {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        }
        let detector = ClipboardManager.shared
        #expect(detector.detectFileType([plain.path]) == .folder)
        #expect(detector.detectFileType([dotted.path]) == .folder)
        #expect(detector.detectFileType([plain.path, dotted.path]) == .folder)
        #expect(detector.detectFileType([application.path]) == .application)
        #expect(detector.detectFileType([plain.path, application.path]) == .file)
        #expect(detector.detectFileType([]) == .file)
    }

    @Test @MainActor
    func additionalFormatsAndMixedSelections() {
        let examples: [(String, ClipContentType)] = [
            ("XLSM", .document), ("key", .document), ("JSON", .document),
            ("swift", .document), ("mobi", .document), ("AVIF", .image),
            ("NEF", .image), ("m2ts", .video), ("m4b", .audio),
            ("lz4", .archive), ("jar", .archive), ("msix", .application),
            ("unrecognized123", .file)
        ]
        for (ext, expected) in examples {
            #expect(ClipboardManager.shared.detectFileType(["/nonexistent/sample.\(ext)"]) == expected)
        }
        #expect(ClipboardManager.shared.detectFileType(["/nonexistent/a.xlsx", "/nonexistent/b.pdf"]) == .document)
        #expect(ClipboardManager.shared.detectFileType(["/nonexistent/a.png", "/nonexistent/b.pdf"]) == .file)
    }
}
