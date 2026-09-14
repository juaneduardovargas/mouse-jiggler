import AppKit
import ApplicationServices
import Foundation

final class JigglerService {
    private let movementDistance: CGFloat = 2
    private var direction: CGFloat = 1

    func jiggle() -> Bool {
        guard let sourceEvent = CGEvent(source: nil) else {
            return false
        }

        let currentLocation = sourceEvent.location
        let displacedLocation = clampToVisibleScreens(
            CGPoint(
                x: currentLocation.x + (movementDistance * direction),
                y: currentLocation.y + (movementDistance * direction * 0.5)
            )
        )

        direction *= -1

        guard postMouseMove(to: displacedLocation) else {
            return false
        }

        usleep(25_000)
        return postMouseMove(to: currentLocation)
    }

    private func postMouseMove(to point: CGPoint) -> Bool {
        guard let event = CGEvent(
            mouseEventSource: nil,
            mouseType: .mouseMoved,
            mouseCursorPosition: point,
            mouseButton: .left
        ) else {
            return false
        }

        event.post(tap: .cghidEventTap)
        return true
    }

    private func clampToVisibleScreens(_ point: CGPoint) -> CGPoint {
        let unionFrame = NSScreen.screens.reduce(CGRect.null) { partialResult, screen in
            partialResult.union(screen.frame)
        }

        guard !unionFrame.isNull else { return point }

        let minX = unionFrame.minX + 1
        let maxX = unionFrame.maxX - 1
        let minY = unionFrame.minY + 1
        let maxY = unionFrame.maxY - 1

        return CGPoint(
            x: min(max(point.x, minX), maxX),
            y: min(max(point.y, minY), maxY)
        )
    }
}
