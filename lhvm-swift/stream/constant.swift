/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

// @Swift: class only exists as a workaround for PAT limitations.
public class Constant<Currency> : ValueStream {
  public typealias SampleOutput = Currency
  
  public var value: Currency
  public var reduce: () -> Currency = { return 1.0 as! Currency}
  
  public init(_ value: Currency) {
    self.value = value
    self.reduce = { return self.value }
  }
}

public final class Number: Constant<Double> {
  public override init(_ value: Double) {
    super.init(value)
  }
}

public final class GraphicsNumber: Constant<CGFloat> {
  public override init(_ value: CGFloat) {
    super.init(value)
  }
}
