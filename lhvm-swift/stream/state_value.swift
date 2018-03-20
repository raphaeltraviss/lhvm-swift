// @Swift: class only exists to work around limitations in protocols with
// associated types.  Not meant to be instantiated.
class StateValue<PlatformSample, SchemaSample, Currency> : StateStream {
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

final class ElapsedTime: StateValue<AppKitSample, HeightmapSample, Double> {
  init() { super.init(\AppKitSample.time_elapsed) }
}
final class MouseX: StateValue<AppKitSample, HeightmapSample, Double> {
  init() { super.init(\AppKitSample.mouse_x) }
}

