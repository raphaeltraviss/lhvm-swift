protocol ValueStream {
  associatedtype SampleOutput
  
  // Nullary computation.
  var reduce: () -> SampleOutput { get }
}

protocol SampleStream {
  associatedtype UserSample
  associatedtype SampleIndex
  associatedtype SampleOutput
  
  // Nullary computation.
  var reduce: (UserSample, SampleIndex) -> SampleOutput { get }
}

protocol FunctionStream {
  associatedtype SampleOutput
  
  // Unary computation.
  var reduce: (SampleOutput) -> SampleOutput { get }
}

protocol MergeStream {
  associatedtype SampleOutput
  
  // Binary computation.
  var reduce: (SampleOutput, SampleOutput) -> SampleOutput { get }
}
