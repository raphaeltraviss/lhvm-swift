// Combinator streams must be preceeded by an InputStream, which produces
// the value to be bound to the StreamParameter referenced by the CombinatorStream.
// Next on the stack, is either a Stream, which will have the parameter value bound to
// it, or another BindParameter, which will cascade with the current StreamParameter.

enum StreamParameter: CustomStringConvertible {
  case constant(Double)
  case amplitude(Double)
  case wavelength(Double)
  case speed(Double)
  case phase_shift(Double)
  case loop_count(Int)
  case duration(Double)
  case interval(Double)
  case sawness(Double)
  case squareness(Double)
  
  var description: String {
    switch self {
    case .constant(let value): return "constant \(value)"
    case .amplitude(let value): return "amplitude \(value)"
    case .wavelength(let value): return "wavelength \(value)"
    case .speed(let value): return "speed \(value)"
    case .phase_shift(let value): return "phase shift \(value)"
    case .loop_count(let value): return "loop count \(value)"
    case .duration(let value): return "duration \(value)"
    case .interval(let value): return "interval \(value)"
      
    // Bogus parameters for testing.
    case .sawness(let value): return "sawness \(value)"
    case .squareness(let value): return "squareness \(value)"
    }
  }
}
