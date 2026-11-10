import AppKit
import Testing
@testable import PasteMemo

@Suite("Image pasteboard representations")
struct ImagePasteboardTests {
    @Test @MainActor
    func fileImageExposesPixelsOnFirstItemWithoutFilenameText() throws {
        let bitmap = try #require(NSBitmapImageRep(
            bitmapDataPlanes: nil, pixelsWide: 2, pixelsHigh: 2,
            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true,
            isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0
        ))
        let png = try #require(bitmap.representation(using: .png, properties: [:]))
        let pb = NSPasteboard(name: .init("pastememo-image-test-\(UUID().uuidString)"))
        defer { pb.releaseGlobally() }
        pb.clearContents()
        ClipboardManager.shared.writeImageToPasteboard(pb, data: png, paths: ["/tmp/截图.png"])
        let first = try #require(pb.pasteboardItems?.first)
        #expect(pb.pasteboardItems?.count == 1)
        #expect(first.string(forType: .fileURL) != nil)
        #expect(first.data(forType: .png) == png)
        #expect(first.data(forType: .tiff) != nil)
        #expect(pb.string(forType: .string) == nil)
    }

    @Test @MainActor
    func multipleImageFilesKeepEveryFileURL() throws {
        let pb = NSPasteboard(name: .init("pastememo-image-test-\(UUID().uuidString)"))
        defer { pb.releaseGlobally() }
        pb.clearContents()
        ClipboardManager.shared.writeImageToPasteboard(pb, data: nil, paths: ["/tmp/a.png", "/tmp/b.png"])
        #expect(pb.pasteboardItems?.count == 2)
        #expect(pb.pasteboardItems?.allSatisfy { $0.string(forType: .fileURL) != nil } == true)
        #expect(pb.string(forType: .string) == nil)
    }
}
