struct ConstantState<Currency> {
  var value: Currency
  init(_ value: Currency) {
    self.value = value
  }
}

// This intermediate class is only necessary to provide something concrete
// to store in the stream stack, due to the ValueStream protocol with assoc types.
class ConstantValue<Currency> : ValueStream {
  typealias SampleOutput = Currency
  var state: ConstantState<Currency>
  var reduce: () -> Currency {
    return {
      return 1.0 as! Currency
    }
  }
  
  init(state: ConstantState<Currency>?) { self.state = state ?? ConstantState<Currency>(1.0 as! Currency) }
  init(_ value: Currency) {
    self.state = ConstantState<Currency>(value)
  }
}

extension ConstantValue where Currency == Double {
  var reduce: () -> Double {
    return { () in
      return self.state.value
    }
  }
  
  convenience init(parameters: [StreamParameter]) {
    let state = parameters.reduce(ConstantState(1.0), { (current_state, parameter) in
      var current_state = current_state
      switch parameter {
      case .constant(let value): current_state.value = value
      default: break
      }
      return current_state;
    })
    self.init(state: state)
  }
}
