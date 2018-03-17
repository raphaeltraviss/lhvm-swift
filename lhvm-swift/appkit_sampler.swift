import Foundation
import AppKit

struct AppKitSample {
  var mouse_x: Double = 0.0
  var mouse_y: Double = 0.0
  var time_elapsed: Double = 0.0
  var time_delta: Double = 0.0
  var keys_pressed: [Int] = []
}


// @TODO: this should be a protocol that we can extend NSView to provide.
// Maybe even a generic "UISampler", that the NSView implementation can provide.
// Maybe LHVM could provide this subclass itself: NSViewSampler
class AppKitSampler: NSView {
  // @TODO: create methods for getting an AppKitSampleState struct out of the
  // NSView.
  func sample() -> AppKitSample {
    return AppKitSample(mouse_x: 1.0, mouse_y: 1.0, time_elapsed: 100.0, time_delta: 0.23, keys_pressed: [45,46])
  }
}

extension Encodable {
  subscript(key: String) -> Any? {
    return dictionary[key]
  }
  var data: Data {
    return try! JSONEncoder().encode(self)
  }
  var dictionary: [String: Any] {
    return (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] ?? [:]
  }
}
