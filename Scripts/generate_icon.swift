import AppKit
import Foundation

let arguments = CommandLine.arguments
guard arguments.count == 2 else {
    fputs("Uso: swift generate_icon.swift <directorio_iconset>\n", stderr)
    exit(1)
}

let outputDirectory = URL(fileURLWithPath: arguments[1], isDirectory: true)
try? FileManager.default.removeItem(at: outputDirectory)
try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)

let iconFiles: [(filename: String, pixels: CGFloat)] = [
    ("icon_16x16.png", 16),
    ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32),
    ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128),
    ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256),
    ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512),
    ("icon_512x512@2x.png", 1024)
]

for iconFile in iconFiles {
    let image = renderIcon(size: iconFile.pixels)
    let destination = outputDirectory.appendingPathComponent(iconFile.filename)
    try save(image: image, to: destination)
}

func renderIcon(size: CGFloat) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()

    let rect = NSRect(x: 0, y: 0, width: size, height: size)
    let cornerRadius = size * 0.23

    let backgroundPath = NSBezierPath(roundedRect: rect, xRadius: cornerRadius, yRadius: cornerRadius)
    let gradient = NSGradient(
        colors: [
            NSColor(calibratedRed: 0.03, green: 0.16, blue: 0.34, alpha: 1),
            NSColor(calibratedRed: 0.02, green: 0.48, blue: 0.62, alpha: 1),
            NSColor(calibratedRed: 0.07, green: 0.72, blue: 0.74, alpha: 1)
        ]
    )!
    gradient.draw(in: backgroundPath, angle: 45)

    let outerGlow = NSBezierPath(ovalIn: rect.insetBy(dx: size * 0.14, dy: size * 0.14))
    NSColor(calibratedWhite: 1, alpha: 0.08).setStroke()
    outerGlow.lineWidth = size * 0.035
    outerGlow.stroke()

    let innerGlow = NSBezierPath(ovalIn: rect.insetBy(dx: size * 0.24, dy: size * 0.24))
    NSColor(calibratedWhite: 1, alpha: 0.12).setStroke()
    innerGlow.lineWidth = size * 0.02
    innerGlow.stroke()

    let arrow = NSBezierPath()
    arrow.move(to: CGPoint(x: size * 0.27, y: size * 0.78))
    arrow.line(to: CGPoint(x: size * 0.44, y: size * 0.30))
    arrow.line(to: CGPoint(x: size * 0.54, y: size * 0.42))
    arrow.line(to: CGPoint(x: size * 0.67, y: size * 0.25))
    arrow.line(to: CGPoint(x: size * 0.76, y: size * 0.31))
    arrow.line(to: CGPoint(x: size * 0.63, y: size * 0.47))
    arrow.line(to: CGPoint(x: size * 0.78, y: size * 0.52))
    arrow.close()

    let shadow = NSShadow()
    shadow.shadowBlurRadius = size * 0.04
    shadow.shadowOffset = NSSize(width: 0, height: -size * 0.01)
    shadow.shadowColor = NSColor(calibratedWhite: 0, alpha: 0.25)
    shadow.set()

    NSColor.white.setFill()
    arrow.fill()

    let motionOne = NSBezierPath()
    motionOne.move(to: CGPoint(x: size * 0.55, y: size * 0.68))
    motionOne.curve(
        to: CGPoint(x: size * 0.82, y: size * 0.76),
        controlPoint1: CGPoint(x: size * 0.63, y: size * 0.78),
        controlPoint2: CGPoint(x: size * 0.74, y: size * 0.80)
    )
    motionOne.lineWidth = size * 0.028
    motionOne.lineCapStyle = .round
    NSColor(calibratedRed: 0.82, green: 0.95, blue: 1, alpha: 1).setStroke()
    motionOne.stroke()

    let motionTwo = NSBezierPath()
    motionTwo.move(to: CGPoint(x: size * 0.50, y: size * 0.59))
    motionTwo.curve(
        to: CGPoint(x: size * 0.86, y: size * 0.68),
        controlPoint1: CGPoint(x: size * 0.60, y: size * 0.72),
        controlPoint2: CGPoint(x: size * 0.75, y: size * 0.73)
    )
    motionTwo.lineWidth = size * 0.024
    motionTwo.lineCapStyle = .round
    motionTwo.stroke()

    let dotRect = NSRect(x: size * 0.72, y: size * 0.30, width: size * 0.10, height: size * 0.10)
    let dot = NSBezierPath(ovalIn: dotRect)
    NSColor(calibratedRed: 1, green: 0.85, blue: 0.30, alpha: 1).setFill()
    dot.fill()

    image.unlockFocus()
    return image
}

func save(image: NSImage, to url: URL) throws {
    guard
        let tiff = image.tiffRepresentation,
        let representation = NSBitmapImageRep(data: tiff),
        let pngData = representation.representation(using: .png, properties: [:])
    else {
        throw NSError(domain: "generate_icon", code: 1, userInfo: [NSLocalizedDescriptionKey: "No se pudo exportar PNG"])
    }

    try pngData.write(to: url)
}
