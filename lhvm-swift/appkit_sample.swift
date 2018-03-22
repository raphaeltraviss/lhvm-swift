/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import AppKit

// @TODO: this should be a protocol that we can extend NSView to provide.
// Maybe even a generic "UISampler", that the NSView implementation can provide.
// Maybe LHVM could provide this subclass itself: NSViewSampler
class SampleView: NSView {
  // @TODO: create methods for getting an AppKitSampleState struct out of the
  // NSView.
  func sample() -> AppKitSample {
    return AppKitSample(
      resolution_x: 100,
      resolution_y: 200,
      mouse_x: 50,
      mouse_y: 75,
      time_elapsed: 100.0,
      time_delta: 0.23,
      keys_pressed: [45,46]
    )
  }
}
