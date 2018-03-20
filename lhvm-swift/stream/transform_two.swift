typealias BinaryFunction<T> = (T, T) -> T

// @Swift: this class only exists to get around protocol with associated type
// limitations--it should be an abstract class, but Swift doesn't have these.
class TransformTwo<Currency> : MergeStream {
  typealias SampleOutput = Currency
  var reduce: BinaryFunction<Currency> = { input1, _ in return input1 }
}

final class Add: TransformTwo<Double> {
  override init() {
    super.init()
    self.reduce = (+)
  }
}

final class Subtract: TransformTwo<Double> {
  override init() {
    super.init()
    self.reduce = (-)
  }
}
final class Multiply: TransformTwo<Double> {
  override init() {
    super.init()
    self.reduce = (*)
  }
}
final class Divide: TransformTwo<Double> {
  override init() {
    super.init()
    self.reduce = (*)
  }
}