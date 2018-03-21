/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation





final class LHVM<SchemaSample, Currency> {
  
  // Again, note that AppKitSample is filled-in, because this LHVM class is actually
  // AppKit-specific.
  typealias StackOp = StreamOp<AppKitSample, SchemaSample, Currency>
  typealias OpStack = [StackOp]
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
  func sample(at app_sample: SchemaSample) -> Currency? {
    let ui_sample = self.ui_sampler?.sample() ?? AppKitSample()
    guard let kernel = self.kernel else { return nil }
    return kernel(ui_sample, app_sample)
  }
  
  func sample(buffer: [SchemaSample]) -> [Currency?] {
    return buffer.map({ sample(at: $0) })
  }

  init(ops the_ops: OpStack) {
    self.opstack = the_ops
    self.kernel = evaluate()
  }
  convenience init?(program: String) {
    guard let the_ops = LHVM.parse(program) else { return nil }
    self.init(ops: the_ops)
  }
  
  
  // MARK: private state and internal API.
  
  // @TODO: ops should be private... after I implement add/remove Collection API.
  // Evaluate and cache a new kernel, every time the stack is mutated.
  var opstack = OpStack() {
    didSet {
      self.kernel = evaluate()
    }
  }
  var ui_sampler: AppKitSampler?
  
  // Cached, evaluated kernel from the OpStack.
  var kernel: ComputeKernel?
  
  func evaluate() -> ComputeKernel? {
    return evaluate_ops(opstack[..<opstack.endIndex]).result
  }
  
  private func evaluate_ops(_ ops: ArraySlice<StackOp>) -> (result: ComputeKernel?, remaining_ops: ArraySlice<StackOp>) {
    guard ops.count > 0 else { return (nil, ops) }
    let current_index = ops.endIndex - 1
    let op = ops[current_index]
    
    let new_slice = ops[..<current_index]
    
    switch op {
    case .input(let constant):
      let constant_kernel: ComputeKernel = { _, _ in return constant.reduce() }
      return (result: constant_kernel, remaining_ops: new_slice)
    case .sample(let sampler):
      // Note: it just so happens that the sampler reduce matches the signature for ComputeKernel.
      return (result: sampler.reduce, remaining_ops: new_slice)
    case .map(let unary_trans):
      let (next_kernel, next_ops) = evaluate_ops(new_slice)
      guard next_kernel != nil else { return ( nil, []) }
      let unary_kernel: ComputeKernel = { p_sample, a_sample in
        return unary_trans.reduce(next_kernel!(p_sample, a_sample))
      }
      return (result: unary_kernel, remaining_ops: next_ops)
    case .combine(let binary_trans):
      let (kernel1, next_ops1) = evaluate_ops(new_slice)
      guard kernel1 != nil else { return ( nil, []) }
      let (kernel2, next_ops2) = evaluate_ops(next_ops1)
      guard kernel2 != nil else { return ( nil, []) }
      let binary_kernel: ComputeKernel = { p_sample, a_sample in
        let result1 = kernel1!(p_sample, a_sample)
        let result2 = kernel2!(p_sample, a_sample)
        return binary_trans.reduce(result1, result2)
      }
      return (result: binary_kernel, remaining_ops: next_ops2)
    default: break
    }
    
    return (nil, [])
  }
  
  func tokenize() -> CFTree? {
    // In the UI, you transform this tree into your NSOutline nodes.
    // @TODO: use CFTreeCreate and the Swift pointer API to return a nested tree.
    return nil
  }
}







extension LHVM: Collection {
  typealias Index = Int
  typealias Element = StackOp
  
  var startIndex: Index { return opstack.startIndex }
  var endIndex: Index { return opstack.endIndex }

  subscript(index: Index) -> Iterator.Element {
    get { return opstack[index] }
  }
  
  // Custom subscript by schema sample returns the computed sample result.
  subscript(index: SchemaSample) -> Currency? {
    get { return self.sample(at: index) }
  }

  func index(after i: Int) -> Int {
    return opstack.index(after: i)
  }
}

extension LHVM where SchemaSample == HeightmapState {
  // @Swift: workaround to conveniently index samples, until Swift supports
  // KeyPaths for tuples.
  subscript(index: (Double, Double)) -> Currency? {
    get { return self.sample(at: HeightmapState(index.0, index.1)) }
  }
}


