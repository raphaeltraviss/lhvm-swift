/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

public struct HeightmapState<NumberType: Comparable>: Comparable {
  var x: NumberType
  var y: NumberType
  init(_ x: NumberType, _ y: NumberType) {
    self.x = x
    self.y = y
  }
  
  
  public static func ==(left: HeightmapState, right: HeightmapState) -> Bool {
    return left.x == right.x && left.y == right.y
  }
  public static func <(left: HeightmapState, right: HeightmapState) -> Bool {
    return left.y < right.y || left.x < right.x
  }
}
