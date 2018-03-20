protocol ValueStream {
  associatedtype Currency
  var reduce: () -> Currency { get }
}

protocol StateStream {
  associatedtype UserSample
  associatedtype SampleIndex
  associatedtype SampleOutput
  var reduce: (UserSample, SampleIndex) -> SampleOutput { get }
}

protocol TransformStream {
  associatedtype SampleOutput
  var reduce: (SampleOutput) -> SampleOutput { get }
}

protocol MergeStream {
  associatedtype SampleOutput
  var reduce: (SampleOutput, SampleOutput) -> SampleOutput { get }
}
