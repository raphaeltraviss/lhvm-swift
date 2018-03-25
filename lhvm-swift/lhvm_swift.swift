/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation



// @TODO: we can't seem to use this class in consumer apps.
public final class MacLhvm<SchemaSample, Currency>: Lhvm<AppKitSample<Double>, SchemaSample, Currency> {
  public override init(ops the_ops: OpStack) {
    super.init(ops: the_ops)
    self.platform_listener = AppKitListener()
  }
}

public class Lhvm<PlatformSample, SchemaSample, Currency> {
  public typealias StackOp = StreamOp<PlatformSample, SchemaSample, Currency>
  public typealias OpStack = [StackOp]
  public typealias ComputeKernel = (PlatformSample, SchemaSample) -> Currency
  
  
  // MARK: public API.
  
  public static func parse(_ program: String) -> OpStack? {
    return OpStack()
  }
  
  public func attach(_ listener: Listener<PlatformSample>) {
    self.platform_listener = listener
  }
  
  public func sample(at app_sample: SchemaSample) -> Currency? {
    guard let platform_sample = platform_listener.report() else { return nil }
    guard let kernel = self.kernel else { return nil }
    return kernel(platform_sample, app_sample)
  }
  
  public func sample(buffer: [SchemaSample]) -> [Currency?] {
    return buffer.map({ sample(at: $0) })
  }

  public init(ops the_ops: OpStack) {
    self.opstack = the_ops
    self.kernel = evaluate()
  }
  public convenience init?(program: String) {
    guard let the_ops = Lhvm.parse(program) else { return nil }
    self.init(ops: the_ops)
  }
  
  
  // MARK: private state and internal API.
  
  // @TODO: ops should be private... after I implement add/remove Collection API.
  // Evaluate and cache a new kernel, every time the stack is mutated.
  public var opstack = OpStack() {
    didSet {
      self.kernel = evaluate()
    }
  }
  
  public var platform_listener: Listener<PlatformSample> = Listener<PlatformSample>()
  
  // Cached, evaluated kernel from the OpStack.
  public var kernel: ComputeKernel?
  
  public func evaluate() -> ComputeKernel? {
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
  
  public func tokenize() -> StreamNode<StackOp>? {
    return tokenize_ops(opstack[..<opstack.endIndex]).0
  }
  
  private func tokenize_ops(_ ops: ArraySlice<StackOp>) -> (StreamNode<StackOp>?, ArraySlice<StackOp>) {
    guard ops.count > 0 else { return (nil, ops) }
    let current_index = ops.endIndex - 1
    let op = ops[current_index]
    let new_slice = ops[..<current_index]
    
    switch op {
    case .input, .sample:
      return (StreamNode(op, at: current_index), new_slice)
    case .map:
      let (next_node, next_ops) = tokenize_ops(new_slice)
      guard next_node != nil else { return ( nil, []) }
      let node = StreamNode(op, at: current_index, child_nodes: [next_node!])
      return (node, next_ops)
    case .combine:
      let (next_node1, next_ops1) = tokenize_ops(new_slice)
      guard next_node1 != nil else { return ( nil, []) }
      
      let (next_node2, next_ops2) = tokenize_ops(next_ops1)
      guard next_node2 != nil else { return ( nil, []) }
      
      let node = StreamNode(op, at: current_index, child_nodes: [next_node1!, next_node2!])
      return (node, next_ops2)
    default: break
    }
    
    return (nil, [])
  }
}







extension Lhvm: Collection {
  public typealias Index = Int
  public typealias Element = StackOp
  
  public var startIndex: Index { return opstack.startIndex }
  public var endIndex: Index { return opstack.endIndex }

  public subscript(index: Index) -> Iterator.Element {
    get { return opstack[index] }
  }
  
  // Custom subscript by schema sample returns the computed sample result.
  public subscript(index: SchemaSample) -> Currency? {
    get { return self.sample(at: index) }
  }

  public func index(after i: Int) -> Int {
    return opstack.index(after: i)
  }
}

extension Lhvm where SchemaSample == HeightmapState<Double> {
  public subscript(x_cycle: Double, y_cycle: Double) -> Currency? {
    get {
      return self.sample(at: HeightmapState<Double>(x_cycle, y_cycle))
    }
  }
}
extension Lhvm where SchemaSample == HeightmapState<CGFloat> {
  public subscript(x_cycle: CGFloat, y_cycle: CGFloat) -> Currency? {
    get {
      return self.sample(at: HeightmapState<CGFloat>(x_cycle, y_cycle))
    }
  }
}


