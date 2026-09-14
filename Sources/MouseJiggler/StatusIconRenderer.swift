import AppKit

/// Draws a template menu bar icon that reflects the current running state.
enum StatusIconRenderer {
    /// Creates a monochrome pointer icon with motion waves while the jiggler is active.
    static func make(isRunning: Bool) -> NSImage {
        let size = NSSize(width: 18, height: 18)
        let image = NSImage(size: size)

        image.lockFocus()

        NSColor.clear.setFill()
        NSBezierPath(rect: NSRect(origin: .zero, size: size)).fill()

        let pointer = NSBezierPath()
        pointer.move(to: CGPoint(x: 3, y: 15))
        pointer.line(to: CGPoint(x: 8, y: 4))
        pointer.line(to: CGPoint(x: 10, y: 8))
        pointer.line(to: CGPoint(x: 13.2, y: 3.2))
        pointer.line(to: CGPoint(x: 14.8, y: 4.3))
        pointer.line(to: CGPoint(x: 11.8, y: 9.2))
        pointer.line(to: CGPoint(x: 15.2, y: 10.3))
        pointer.close()

        NSColor.black.setFill()
        pointer.fill()

        if isRunning {
            let waveOne = NSBezierPath()
            waveOne.move(to: CGPoint(x: 11.5, y: 13.5))
            waveOne.curve(
                to: CGPoint(x: 15.5, y: 15.3),
                controlPoint1: CGPoint(x: 12.6, y: 15.1),
                controlPoint2: CGPoint(x: 14.3, y: 15.8)
            )
            waveOne.lineWidth = 1.6
            NSColor.black.setStroke()
            waveOne.stroke()

            let waveTwo = NSBezierPath()
            waveTwo.move(to: CGPoint(x: 10.4, y: 11.2))
            waveTwo.curve(
                to: CGPoint(x: 16.2, y: 13.8),
                controlPoint1: CGPoint(x: 12.0, y: 13.3),
                controlPoint2: CGPoint(x: 14.6, y: 14.1)
            )
            waveTwo.lineWidth = 1.6
            waveTwo.stroke()
        }

        image.unlockFocus()
        image.isTemplate = true
        return image
    }
}
