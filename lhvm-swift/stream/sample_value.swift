class SampleValue<PlatformSample, SchemaSample, Currency> : SampleStream {
  typealias UserSample = PlatformSample
  typealias SampleIndex = SchemaSample
  typealias SampleOutput = Currency
  
  var reduce: (_ platform_sample: PlatformSample, _ schema_sample: SchemaSample) -> Currency
  
  init(_ platform_property: KeyPath<PlatformSample, Currency>) {
    self.reduce = { platform, _ in
      return platform[keyPath: platform_property]
    }
  }
  init(_ schema_property: KeyPath<SchemaSample, Currency>) {
    self.reduce = { _, schema in
      return schema[keyPath: schema_property]
    }
  }
}

// @TODO: some of the samplers, such as Timer and Mouse, have their own
// state parameters that affect the sampled output value.
