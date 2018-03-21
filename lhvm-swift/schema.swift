/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

struct HeightmapState: Comparable {
  var x: Double
  var y: Double
  init(_ x: Double, _ y: Double) {
    self.x = x
    self.y = y
  }
  
  static func ==(left: HeightmapState, right: HeightmapState) -> Bool {
    return left.x == right.x && left.y == right.y
  }
  static func <(left: HeightmapState, right: HeightmapState) -> Bool {
    return left.y < right.y || left.x < right.x
  }
}
