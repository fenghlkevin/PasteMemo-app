import SwiftUI
import AppKit

/// Owns the card's hit region so secondary clicks are handled by AppKit,
/// independently of the floating panel's SwiftUI gesture routing.
struct NativeContextMenu<Content: View>: NSViewRepresentable {
    struct Action {
        let title: String
        var keyEquivalent: String = ""
        var modifiers: NSEvent.ModifierFlags = []
        let perform: () -> Void
    }

    let content: Content
    let onClick: () -> Void
    let actions: () -> [Action]

    func makeNSView(context: Context) -> CardHostingView {
        CardHostingView(rootView: content, onClick: onClick, actions: actions)
    }

    func updateNSView(_ nsView: CardHostingView, context: Context) {
        nsView.rootView = content
        nsView.onClick = onClick
        nsView.actions = actions
    }

    final class CardHostingView: NSHostingView<Content> {
        var onClick: () -> Void
        var actions: () -> [Action]

        init(rootView: Content, onClick: @escaping () -> Void, actions: @escaping () -> [Action]) {
            self.onClick = onClick
            self.actions = actions
            super.init(rootView: rootView)
        }

        required init(rootView: Content) { fatalError("Use the action initializer") }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

        override var mouseDownCanMoveWindow: Bool { false }

        override func hitTest(_ point: NSPoint) -> NSView? {
            super.hitTest(point) == nil ? nil : self
        }

        override func mouseDown(with event: NSEvent) {
            if event.modifierFlags.contains(.control) {
                rightMouseDown(with: event)
            } else {
                onClick()
            }
        }

        override func rightMouseDown(with event: NSEvent) {
            let menu = NSMenu()
            for action in actions() {
                menu.addItem(ActionMenuItem(title: action.title, keyEquivalent: action.keyEquivalent, modifiers: action.modifiers, perform: action.perform))
            }
            NSMenu.popUpContextMenu(menu, with: event, for: self)
        }
    }
}

@MainActor
private final class ActionMenuItem: NSMenuItem {
    private let perform: () -> Void

    init(title: String, keyEquivalent: String, modifiers: NSEvent.ModifierFlags, perform: @escaping () -> Void) {
        self.perform = perform
        super.init(title: title, action: #selector(invoke), keyEquivalent: keyEquivalent)
        keyEquivalentModifierMask = modifiers
        target = self
    }

    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc private func invoke() { perform() }
}
