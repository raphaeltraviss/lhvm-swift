enum BinaryTransformFunction {
  case add
  case subtract
  case multiply
  case divide
}

class BinaryTransform<Currency> : MergeStream {
  typealias SampleOutput = Currency
  typealias BinaryFunction = (Currency, Currency) -> Currency
  
  static func build_reducer(transform: BinaryTransformFunction, parameters: [StreamParameter]) -> BinaryFunction {
    return { input1, input2 in return 1.0 as! Currency }
  }
  
  var reduce: BinaryFunction
  
  init(_ transform: BinaryTransformFunction, parameters: [StreamParameter]) {
    self.reduce = BinaryTransform.build_reducer(transform: transform, parameters: parameters)
  }
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
}
