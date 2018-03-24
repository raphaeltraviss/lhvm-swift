/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

public typealias BinaryFunction<T> = (T, T) -> T

// @Swift: this class only exists to get around protocol with associated type
// limitations--it should be an abstract class, but Swift doesn't have these.
public class TransformTwo<Currency> : MergeStream {
  public typealias SampleOutput = Currency
  public var reduce: BinaryFunction<Currency> = { input1, _ in return input1 }
}

public final class Add: TransformTwo<Double> {
  public override init() {
    super.init()
    self.reduce = (+)
  }
}

public final class Subtract: TransformTwo<Double> {
  public override init() {
    super.init()
    self.reduce = (-)
  }
}
public final class Multiply: TransformTwo<Double> {
  public override init() {
    super.init()
    self.reduce = (*)
  }
}
public final class Divide: TransformTwo<Double> {
  public override init() {
    super.init()
    self.reduce = (*)
  }
}
