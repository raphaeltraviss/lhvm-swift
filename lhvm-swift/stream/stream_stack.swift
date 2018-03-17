import Foundation

// An individual stream operation is valid only for a certain platform sample
// type, a certain schema, and a certain currency.
// The StreamStack can, optionally, take the three generic type, and restrict
// everything inside of its stack to be of the same type--then you could embed
// StreamStacks within StreamStacks.
enum StreamOp<PlatformSample, SchemaSample, Currency>{
  case input(ConstantValue<Currency>)
  case request(SampleValue<PlatformSample, SchemaSample, Currency>)
  case map(UnaryTransform<Currency>)
  case combine(BinaryTransform<Currency>)
  case bind(StreamParameter)
}


extension Array where Element == StreamOp<AppKitSample, HeightmapSample, Double> {
  func evaluate() -> (AppKitSample, HeightmapSample) -> Double {
    return { (user_sample, app_sample) in return 1.0 }
  }
}
