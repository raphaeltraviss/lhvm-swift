import Foundation





final class LHVM<SchemaSample, Currency> {
  
  // Again, note that AppKitSample is filled-in, because this LHVM class is actually
  // AppKit-specific.
  typealias OpStack = [StreamOp<AppKitSample, SchemaSample, Currency>]
  typealias ComputeKernel = (AppKitSample, SchemaSample) -> Currency
  
  
  // MARK: public APi.
  
  static func parse(_ program: String) -> OpStack? {
    return OpStack()
  }
  
  func attach(sampler: AppKitSampler) {
    // build and set ui_sampler.
    // recalculate the kernel, if necessarry.
    // hand the caller back... something.
  }
  
  init() {}
  
  // MARK: private state and internal API.
  
  private var _ops = OpStack()
  private var ui_sampler: AppKitSampler?
  private var kernel: ComputeKernel?
}



// Extend the LHVM subclass for every schema and output type we want.
extension LHVM where SchemaSample == HeightmapSample, Currency == Double {
  typealias HeightmapOpstack = [StreamOp<AppKitSample, HeightmapSample, Double>]
  
  var ops: HeightmapOpstack {
    get { return self._ops }
    set {
      self._ops = ops
      self.kernel = ops.evaluate()
    }
  }
  func sample(at app_sample: SchemaSample) -> Double {
    let ui_sample = self.ui_sampler?.sample() ?? AppKitSample()
    guard self.kernel != nil else { return 0.0 }
    return self.kernel!(ui_sample, app_sample)
  }
  
  func sample(buffer: [SchemaSample]) -> [Currency] {
    return buffer.map({ sample(at: $0) })
  }
  
  convenience init?(program: String) {
    guard let the_ops = LHVM.parse(program) else { return nil }
    self.init(ops: the_ops)
  }
  convenience init(ops the_ops: HeightmapOpstack) {
    self.init()
    self.ops = the_ops
  }

}
