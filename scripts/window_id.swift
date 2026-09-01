import CoreGraphics
import Foundation

let windows = CGWindowListCopyWindowInfo([.optionAll], kCGNullWindowID) as? [[String: Any]] ?? []
let expectedPID = ProcessInfo.processInfo.environment["CLIPGRID_PID"].flatMap(Int.init)
let candidates = windows.compactMap { info -> (id: Int, area: CGFloat)? in
    guard (info[kCGWindowOwnerName as String] as? String) == "ClipGrid",
          (info[kCGWindowName as String] as? String) == "ClipGrid",
          let number = info[kCGWindowNumber as String] as? Int,
          let ownerPID = info[kCGWindowOwnerPID as String] as? Int,
          expectedPID == nil || ownerPID == expectedPID,
          let dictionary = info[kCGWindowBounds as String] as? [String: Any],
          let bounds = CGRect(dictionaryRepresentation: dictionary as CFDictionary) else { return nil }
    return (number, bounds.width * bounds.height)
}

if let window = candidates.max(by: { $0.area < $1.area }) {
    print(window.id)
}
