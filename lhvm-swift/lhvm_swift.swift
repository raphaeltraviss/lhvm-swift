import Foundation





final class LHVM<SchemaSample, Currency> {
  
  typealias Stack = [StreamOp<AppKitSample, SchemaSample, Currency>]
  
  // MARK: public APi.
  
  // @TODO: this method would change type, based on the LHVM subtype--the sampler type is NOT
  // expressed in the generic parameters of the LHVM instance: you should be able to use
  // the same LHVM subclass for multiple IO (schema) types.
  func attach(sampler: AppKitSampler) {
    // build and set ui_sampler.
    // recalculate stack_sampler, if necessarry.
    // hand the caller back... something.
  }
  func load(program: String) {
    // change the program into ops
    // call load(ops:).
  }
  
  
  // MARK: internal types.
  
  typealias Compute0 = (AppKitSample, SchemaSample) -> Currency?
  typealias Compute1 = (AppKitSample, SchemaSample, Currency) -> Currency?
  typealias Compute2 = (AppKitSample, SchemaSample, Currency, Currency) -> Currency?
 
  
  
  
  
  
  
  // MARK: private state and internal API.
  
  // @TODO: how do we do this?  How do we seal the arity of the functions inside of
  // the opstack?? We want these functions to be entered dymanimally, at compile time
  // and at run time.
  private func evaluate(ops: Stack) -> Compute0 {
    func return_one(x: AppKitSample, y: SchemaSample) -> Currency? { return 1.0 as! Currency }
    return return_one
  }
  
  private var stream_stack = Stack()
  
  // For now, we are ignoring the platform sampler, and assuming that we are getting
  // all of our sample data through an AppKit NSView.
  private var ui_sampler: AppKitSampler?
  
  private var stack_sampler: Compute0?
}

// But, sadly, we can't do any of these calculations generically--that means we'll have to
// extend the LHVM subclass for every schema and output type we want.
extension LHVM where SchemaSample == (Int, Int), Currency == Double {
  func load(ops: Stack) {
    self.stack_sampler = evaluate(ops: ops)
  }
  
  
  
  func sample(at schema_sample: SchemaSample) -> Currency {
    let ui_sample = ui_sampler?.sample() ?? AppKitSample()
    return stack_sampler!(ui_sample, schema_sample) ?? 0.0
  }
  
  func sample(buffer: [SchemaSample]) -> [Currency] {
    // @TODO: here's where we'd take the sampler function, compile it to Metal shading language,
    // load it up on the GPU, and return results.
    // We'd need additional state to hold the compiled program, and invalidate it if the
    // user changes the stack.
    return buffer.map({ sample(at: $0) })
  }
  
  // Processes the ops in the stream stack, and creates a nested closure, that, when
  // provided the necessary state arguments, can produce the value for any samply point,
  // at any time: this is called the "stack sampler".
  private func evaluate(_ ops: Stack) -> Compute0 {
    return { index, platform_sample in
      return 2.0
    }
  }
}
