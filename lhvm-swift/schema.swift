/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

// @Swift: implementing the schema sample as a struct, because tuples do
// no work with KeyPath.  Once KeyPath works with tuples, then we can change
// this to a (Double, Double).
struct HeightmapState {
  var x: Double
  var y: Double
  init(_ x: Double, _ y: Double) {
    self.x = x
    self.y = y
  }
}
