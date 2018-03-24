/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

public typealias UnaryFunction<T> = (T) -> T

public class TransformOne<Currency> : TransformStream {
  public typealias SampleOutput = Currency
  public var reduce: UnaryFunction<Currency> = { input1 in return input1 }
}

public class ScaleTen: TransformOne<Double> {
  public override init() {
    super.init()
    self.reduce = { input in return input * 10.0 }
  }
}

public class SimpleSine: TransformOne<Double> {
  public override init() {
    super.init()
    self.reduce = (sin)
  }
}
