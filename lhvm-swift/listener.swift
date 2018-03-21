/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

struct AppKitSample {
  var resolution_x: Double = 0.0
  var resolution_y: Double = 0.0
  var mouse_x: Double = 0.0
  var mouse_y: Double = 0.0
  var time_elapsed: Double = 0.0
  var time_delta: Double = 0.0
  var keys_pressed: [Int] = []
}

class Listener<PlatformSample> {
  var report: () -> PlatformSample? = { return nil }
}


final class AppKitListener: Listener<AppKitSample> {
  override init() {
    super.init()
    self.report = { return AppKitSample() }
  }
}
