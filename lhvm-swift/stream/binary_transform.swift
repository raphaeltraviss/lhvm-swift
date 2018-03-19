enum BinaryTransformFunction {
  case add
  case subtract
  case multiply
  case divide
}

class BinaryTransform<Currency> : MergeStream {
  typealias SampleOutput = Currency
  typealias BinaryFunction = (Currency, Currency) -> Currency
  
  var reduce: BinaryFunction = { _, _ in return 1.0 as! Currency }

  init() {}
}

extension BinaryTransform where Currency == Double {
  func build_reducer(transform: BinaryTransformFunction, parameters: [StreamParameter]) -> BinaryFunction {
    switch transform {
    case .add: return (+)
    case .subtract: return (-)
    case .multiply: return (*)
    case .divide: return (/)
    }
  }
  
  convenience init(_ transform: BinaryTransformFunction, parameters: [StreamParameter]) {
    self.init()
    self.reduce = build_reducer(transform: transform, parameters: parameters)
  }
}
