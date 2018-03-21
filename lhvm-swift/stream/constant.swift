/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

// @Swift: class only exists as a workaround for PAT limitations.
class Constant<Currency> : ValueStream {
  typealias SampleOutput = Currency
  
  var value: Currency
  var reduce: () -> Currency = { return 1.0 as! Currency}
  
  init(_ value: Currency) {
    self.value = value
    self.reduce = { return self.value }
  }
}

final class Number: Constant<Double> {
  override init(_ value: Double) {
    super.init(value)
  }
}
