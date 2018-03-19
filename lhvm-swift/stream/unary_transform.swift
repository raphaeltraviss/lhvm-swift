// @TODO: don't these need to be ComputeKernel, in case you pass them a full
// receptor->transform->perceptor stream as their input?
typealias ComputedDouble = () -> Double

func return_one() -> Double { return 1.0 }

struct SineState {
  var speed: ComputedDouble = return_one
  var amplitude: ComputedDouble = return_one
  var wavelength: ComputedDouble = return_one
  var phase_shift: ComputedDouble = return_one
  
  init() {}
  
  init(from_parameters parameters: [StreamParameter]) {
    self = parameters.reduce(SineState(), { (current_state, parameter) in
      var current_state = current_state
      switch parameter {
      case .speed(let get_value): current_state.speed = get_value
      case .amplitude(let get_value): current_state.amplitude = get_value
      case .wavelength(let get_value): current_state.wavelength = get_value
      case .phase_shift(let get_value): current_state.phase_shift = get_value
      default: break
      }
      return current_state;
    })
  }
}

struct SawState {
  var sawness: ComputedDouble = return_one
  
  init() {}
  
  init(from_parameters parameters: [StreamParameter]) {
    self = parameters.reduce(SawState(), { (current_state, parameter) in
      var current_state = current_state
      switch parameter {
      case .sawness(let get_value): current_state.sawness = get_value
      default: break
      }
      return current_state;
    })
  }
}

struct SquareState {
  var squareness: ComputedDouble = return_one

  init() {}
  
  init(from_parameters parameters: [StreamParameter]) {
    self = parameters.reduce(SquareState(), { (current_state, parameter) in
      var current_state = current_state
      switch parameter {
      case .squareness(let get_value): current_state.squareness = get_value
      default: break
      }
      return current_state;
    })
  }
}

enum UnaryTransformFunction {
  case sine(SineState?) // If no values are supplied, use the defaults
  case saw(SawState?)
  case square(SquareState?)
}

class UnaryTransform<Currency> : FunctionStream {
  typealias SampleOutput = Currency
  
  // Public method to re-generate the reducer when a user changes parameters.
  // So every time a user changes parameters, the program will need to 1) Look through
  // the stack for the bind op 2) change the value after the op 3) evaluate the entire
  // stack 4) re-set the master builder function.
  // This is not acceptable when just changing constant parameters via the dials--we need
  // the transforms to save their own state.
  static func build_reducer(transform: UnaryTransformFunction, parameters: [StreamParameter]) -> ((Currency) -> Currency) {
    return { input in return 1.0 as! Currency }
  }
  
  var reduce: (Currency) -> Currency
  
  // We hold onto any contant values that the user has set, and store them here, which
  // are continually being referenced by the reducer function and included in the
  // calculation.  This saves us from having to re-evaluate the stack, every time a
  // simple value changes.
  // On the other hand, dynamically-calculated values via StreamParameter ops cannot
  // be stored here, and they override whatever is set in here.
  // The flow of truth is `bind` op values -> saved state -> default values.
  // The public can change these at any time.
  var sine_state = SineState()
  var saw_state = SawState()
  var square_state = SquareState()
  
  init(_ transform: UnaryTransformFunction, parameters: [StreamParameter]) {
    self.reduce = UnaryTransform.build_reducer(transform: transform, parameters: parameters)
  }
}


// @TODO: if we bind any sort of function to a parameter value, then we need to store the
// function someplace too.  Perhaps the struct state should store functions instead of values?
// The functions could produce the type of value the parameter expects.  Then, these functions
// could be generated directly by the user operating the UI, or by re-evaluating the stack.
extension UnaryTransform where Currency == Double {
  func build_reducer(transform: UnaryTransformFunction, parameters: [StreamParameter]) -> ((Currency) -> Currency) {
    switch transform {
    case .sine:
      self.sine_state = SineState(from_parameters: parameters)
      return { input in return sin((input * self.sine_state.speed() + self.sine_state.phase_shift()) * self.sine_state.amplitude()) }
    case .saw:
      self.saw_state = SawState(from_parameters: parameters)
      return { input in self.saw_state.sawness() }
    case .square:
      self.square_state = SquareState(from_parameters: parameters)
      return { input in return self.square_state.squareness() }
    }
  }
}

