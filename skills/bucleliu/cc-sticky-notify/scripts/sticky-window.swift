// cc-sticky-notify — native macOS floating sticky note
// CLI arg: path to a content file (one line per notification line)
// Build: swiftc sticky-window.swift -o sticky-notify-app
// Usage: ./sticky-notify-app /tmp/cc-sticky-notify-myproject.txt

import Cocoa

class StickyWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

// Label subclass that passes mouse events through to the parent card view.
// NSTextField normally consumes mouseDown/mouseUp, blocking the card tap.
class PassthroughLabel: NSTextField {
    override func hitTest(_ point: NSPoint) -> NSView? { nil }
}

// Custom card view: tracks mouseDown/mouseUp to detect a tap (not drag)
// without interfering with subview buttons or the window's move-by-background.
class StickyCardView: NSView {
    var closeBtnFrame: NSRect = .zero
    var onTap: (() -> Void)?
    private var mouseDownPt: NSPoint = .zero

    override func mouseDown(with event: NSEvent) {
        mouseDownPt = convert(event.locationInWindow, from: nil)
        super.mouseDown(with: event)
    }

    override func mouseUp(with event: NSEvent) {
        let pt = convert(event.locationInWindow, from: nil)
        let dist = hypot(pt.x - mouseDownPt.x, pt.y - mouseDownPt.y)
        if dist < 5 && !closeBtnFrame.contains(pt) {
            onTap?()
        }
        super.mouseUp(with: event)
    }

    // Accept the first mouse-down even when the window is not key,
    // so a single click triggers the tap without first activating the window.
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: StickyWindow!
    let contentFilePath: String
    let pidFilePath: String
    var fileWatchSource: DispatchSourceFileSystemObject?
    var headerLabel: PassthroughLabel!
    var metaLabel: PassthroughLabel!
    var focusFilePath: String
    var closeBtn: NSButton!
    var slotFilePath: String

    init(contentFilePath: String) {
        self.contentFilePath = contentFilePath
        let base = contentFilePath.hasSuffix(".txt")
            ? String(contentFilePath.dropLast(4))
            : contentFilePath
        self.pidFilePath   = base + ".pid"
        self.focusFilePath = base + ".focus"
        self.slotFilePath  = base + ".slot"
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Write PID file so notify.sh can detect this running instance
        let pid = ProcessInfo.processInfo.processIdentifier
        try? String(pid).write(toFile: pidFilePath, atomically: true, encoding: .utf8)

        guard let screen = NSScreen.main else { NSApp.terminate(nil); return }

        let noteW: CGFloat = 300
        let noteH: CGFloat = 90
        let margin: CGFloat = 20
        let vis = screen.visibleFrame

        // slotStep = full window height + 8pt gap → windows never overlap
        let slotStep: CGFloat = noteH + 8
        // How many non-overlapping windows fit on this screen
        let maxNoCoverSlots = max(1, min(10, Int((vis.height - noteH - margin) / slotStep) + 1))
        let maxSlots = maxNoCoverSlots + 2  // cycling fallback pool
        var slot = 0

        var occupiedSlots = Set<Int>()
        let tmpDir = URL(fileURLWithPath: "/tmp")
        if let files = try? FileManager.default.contentsOfDirectory(at: tmpDir, includingPropertiesForKeys: nil) {
            for file in files
                where file.lastPathComponent.hasPrefix("cc-sticky-notify-") && file.pathExtension == "slot" {
                let pidFile = file.deletingPathExtension().appendingPathExtension("pid")
                if let pidStr = try? String(contentsOf: pidFile, encoding: .utf8),
                   let pid = Int32(pidStr.trimmingCharacters(in: .whitespacesAndNewlines)),
                   kill(pid, 0) == 0,
                   let slotStr = try? String(contentsOf: file, encoding: .utf8),
                   let s = Int(slotStr.trimmingCharacters(in: .whitespacesAndNewlines)) {
                    occupiedSlots.insert(s)
                }
            }
        }

        if occupiedSlots.count >= maxNoCoverSlots {
            // All non-overlap slots taken — cycle via shared counter
            let cycleFile = "/tmp/cc-sticky-notify-slot"
            if let data = try? Data(contentsOf: URL(fileURLWithPath: cycleFile)),
               let str = String(data: data, encoding: .utf8),
               let n = Int(str.trimmingCharacters(in: .whitespacesAndNewlines)) {
                slot = n % maxSlots
            }
            try? String((slot + 1) % maxSlots).write(toFile: cycleFile, atomically: true, encoding: .utf8)
        } else {
            // Pick the lowest unoccupied slot in 0..<maxNoCoverSlots
            for s in 0..<maxNoCoverSlots where !occupiedSlots.contains(s) {
                slot = s
                break
            }
        }
        try? String(slot).write(toFile: slotFilePath, atomically: true, encoding: .utf8)

        let x = vis.maxX - noteW - margin
        let y = vis.maxY - noteH - margin - CGFloat(slot) * slotStep

        window = StickyWindow(
            contentRect: NSRect(x: x, y: y, width: noteW, height: noteH),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.level = .floating
        window.isReleasedWhenClosed = false
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = true
        window.isMovableByWindowBackground = true

        // Card view: rounded corners + warm cream-yellow background
        let cardView = StickyCardView(frame: NSRect(x: 0, y: 0, width: noteW, height: noteH))
        cardView.wantsLayer = true
        cardView.layer?.backgroundColor = NSColor(calibratedRed: 0.98, green: 0.96, blue: 0.72, alpha: 1.0).cgColor
        cardView.layer?.cornerRadius = 12
        cardView.layer?.masksToBounds = true
        window.contentView = cardView

        // Left amber accent bar
        let accentBar = NSView(frame: NSRect(x: 0, y: 0, width: 5, height: noteH))
        accentBar.wantsLayer = true
        accentBar.layer?.backgroundColor = NSColor(calibratedRed: 0.95, green: 0.62, blue: 0.12, alpha: 1.0).cgColor
        cardView.addSubview(accentBar)

        let rowY: CGFloat = noteH - 28

        // Header label: 13pt semibold, dark brown (same row as close button)
        headerLabel = PassthroughLabel(labelWithString: "")
        headerLabel.frame = NSRect(x: 16, y: rowY, width: noteW - 44, height: 20)
        headerLabel.font = NSFont.systemFont(ofSize: 13, weight: .semibold)
        headerLabel.textColor = NSColor(calibratedRed: 0.15, green: 0.10, blue: 0.0, alpha: 1.0)
        headerLabel.lineBreakMode = .byTruncatingTail
        cardView.addSubview(headerLabel)

        // Close button (top-right ✕, same row as header)
        closeBtn = NSButton(frame: NSRect(x: noteW - 26, y: rowY, width: 20, height: 20))
        closeBtn.attributedTitle = NSAttributedString(string: "✕", attributes: [
            .foregroundColor: NSColor(calibratedRed: 0.45, green: 0.35, blue: 0.15, alpha: 0.7),
            .font: NSFont.systemFont(ofSize: 12, weight: .medium)
        ])
        closeBtn.isBordered = false
        closeBtn.target = NSApp
        closeBtn.action = #selector(NSApplication.terminate(_:))
        cardView.addSubview(closeBtn)

        // Divider line: amber, 1pt
        let divider = NSView(frame: NSRect(x: 16, y: rowY - 4, width: noteW - 24, height: 1))
        divider.wantsLayer = true
        divider.layer?.backgroundColor = NSColor(calibratedRed: 0.85, green: 0.72, blue: 0.35, alpha: 0.7).cgColor
        cardView.addSubview(divider)

        // Meta label: 12pt medium, colon-aligned via tab stop at 58pt
        metaLabel = PassthroughLabel(wrappingLabelWithString: "")
        metaLabel.frame = NSRect(x: 16, y: 10, width: noteW - 24, height: rowY - 18)
        cardView.addSubview(metaLabel)

        // Load initial content from file
        let initialText = (try? String(contentsOfFile: contentFilePath, encoding: .utf8)) ?? ""
        updateLabels(from: initialText)

        // Watch content file for in-place updates when notify.sh writes new content
        let fd = open(contentFilePath, O_EVTONLY)
        if fd >= 0 {
            let source = DispatchSource.makeFileSystemObjectSource(
                fileDescriptor: fd, eventMask: .write, queue: .main)
            source.setEventHandler { [weak self] in self?.reloadContent() }
            source.setCancelHandler { close(fd) }
            source.resume()
            fileWatchSource = source
        }

        // Tap anywhere (outside close button) to focus the originating terminal/IDE
        cardView.closeBtnFrame = closeBtn.frame
        cardView.onTap = { [weak self] in self?.focusTerminal() }

        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: false)

        // Auto-close: default 1 hour; override with CC_STICKY_NOTIFY_CLOSE_TIMEOUT env var (seconds)
        let timeout: Double
        if let envVal = ProcessInfo.processInfo.environment["CC_STICKY_NOTIFY_CLOSE_TIMEOUT"],
           let seconds = Double(envVal), seconds > 0 {
            timeout = seconds
        } else {
            timeout = 3600
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
            NSApp.terminate(nil)
        }
    }

    func focusTerminal() {
        guard let raw = try? String(contentsOfFile: focusFilePath, encoding: .utf8) else { return }
        let appName = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !appName.isEmpty else { return }
        // Match by executable name (e.g. "idea") or display name (e.g. "IntelliJ IDEA")
        // NSWorkspace is more reliable than `tell application X to activate` for non-standard names
        if let app = NSWorkspace.shared.runningApplications.first(where: {
            $0.executableURL?.lastPathComponent == appName || $0.localizedName == appName
        }) {
            app.activate(options: [])
        }
    }

    func reloadContent() {
        guard let text = try? String(contentsOfFile: contentFilePath, encoding: .utf8) else { return }
        updateLabels(from: text)
        animatePulse()
    }

    // Brief scale-bounce so the user notices the content has changed
    func animatePulse() {
        guard let layer = window?.contentView?.layer else { return }
        let pulse = CAKeyframeAnimation(keyPath: "transform.scale")
        pulse.values   = [1.0, 1.05, 0.97, 1.0]
        pulse.keyTimes = [0,   0.3,  0.7,  1.0]
        pulse.duration = 0.32
        pulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        layer.add(pulse, forKey: "updatePulse")
    }

    func updateLabels(from text: String) {
        let lines = text.components(separatedBy: "\n").filter { !$0.isEmpty }
        let headerText = lines.first ?? ""
        let metaLines = lines.dropFirst().map { line -> String in
            if let colonIdx = line.firstIndex(of: ":") {
                let key = String(line[...colonIdx])
                let value = line[line.index(after: colonIdx)...].trimmingCharacters(in: .whitespaces)
                return "\(key)\t\(value)"
            }
            return line
        }
        let metaText = metaLines.joined(separator: "\n")

        headerLabel.stringValue = headerText

        let metaPS = NSMutableParagraphStyle()
        metaPS.tabStops = [NSTextTab(textAlignment: .left, location: 58)]
        metaPS.lineSpacing = 3
        let metaAttrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 12, weight: .medium),
            .foregroundColor: NSColor(calibratedRed: 0.30, green: 0.20, blue: 0.05, alpha: 1.0),
            .paragraphStyle: metaPS
        ]
        metaLabel.attributedStringValue = NSAttributedString(string: metaText, attributes: metaAttrs)
    }

    func applicationWillTerminate(_ notification: Notification) {
        fileWatchSource?.cancel()
        try? FileManager.default.removeItem(atPath: pidFilePath)
        try? FileManager.default.removeItem(atPath: focusFilePath)
        try? FileManager.default.removeItem(atPath: slotFilePath)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

let contentFilePath = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : ""
let app = NSApplication.shared
app.setActivationPolicy(.accessory)   // Hide from Dock
let delegate = AppDelegate(contentFilePath: contentFilePath)
app.delegate = delegate
app.run()
