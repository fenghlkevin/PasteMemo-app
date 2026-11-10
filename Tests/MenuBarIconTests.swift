import AppKit
import Testing
@testable import PasteMemo

@Suite("Menu bar icon pixels")
struct MenuBarIconTests {
    @Test @MainActor
    func iconContainsVisiblePixelsInEveryState() throws {
        for filled in [false, true] {
            for state in 0..<3 {
                let image = try #require(PasteMemoApp.menuBarIcon(
                    paused: state == 1, relay: state == 2, filled: filled
                ))
                #expect(image.isTemplate)
                #expect(image.size == NSSize(width: 18, height: 18))
                let data = try #require(image.tiffRepresentation)
                let bitmap = try #require(NSBitmapImageRep(data: data))
                var visible = false
                var transparent = false
                for y in 0..<bitmap.pixelsHigh {
                    for x in 0..<bitmap.pixelsWide {
                        let alpha = bitmap.colorAt(x: x, y: y)?.alphaComponent ?? 0
                        visible = visible || alpha > 0.5
                        transparent = transparent || alpha < 0.1
                    }
                }
                #expect(visible, "Icon must not be an empty transparent image")
                #expect(transparent, "Template must preserve a transparent background")
            }
        }
    }
}
