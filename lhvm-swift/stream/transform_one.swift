typealias UnaryFunction<T> = (T) -> T

class TransformOne<Currency> : TransformStream {
  typealias SampleOutput = Currency
  var reduce: UnaryFunction<Currency> = { input1 in return input1 }
}

class ScaleTen: TransformOne<Double> {
  override init() {
    super.init()
    self.reduce = { input in return input * 10.0 }
  }
}

class SimpleSine: TransformOne<Double> {
  override init() {
    super.init()
    self.reduce = (sin)
  }
}
