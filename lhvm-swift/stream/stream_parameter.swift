// Combinator streams must be preceeded by an InputStream, which produces
// the value to be bound to the StreamParameter referenced by the CombinatorStream.
// Next on the stack, is either a Stream, which will have the parameter value bound to
// it, or another BindParameter, which will cascade with the current StreamParameter.

enum StreamParameter: CustomStringConvertible {
  case constant(Double)
  case amplitude(ComputedDouble)
  case wavelength(ComputedDouble)
  case speed(ComputedDouble)
  case phase_shift(ComputedDouble)
  case loop_count(Int)
  case duration(ComputedDouble)
  case interval(ComputedDouble)
  case sawness(ComputedDouble)
  case squareness(ComputedDouble)
  
  var description: String {
    switch self {
    case .constant(let value): return "constant \(value)"
    case .amplitude(let get_value): return "amplitude \(get_value())"
    case .wavelength(let get_value): return "wavelength \(get_value())"
    case .speed(let get_value): return "speed \(get_value())"
    case .phase_shift(let get_value): return "phase shift \(get_value())"
    case .loop_count(let value): return "loop count \(value)"
    case .duration(let get_value): return "duration \(get_value())"
    case .interval(let get_value): return "interval \(get_value())"
      
    // Bogus parameters for testing.
    case .sawness(let get_value): return "sawness \(get_value())"
    case .squareness(let get_value): return "squareness \(get_value())"
    }
  }
}
