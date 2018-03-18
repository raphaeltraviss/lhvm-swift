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
  typealias OpStack = [StreamOp<AppKitSample, HeightmapSample, Double>]
  typealias ComputeKernel = (AppKitSample, HeightmapSample) -> Double
  
  // @Swift: needed to be able to use array slices, for some reason.
  subscript(_ range: CountableClosedRange<Int>) -> ArraySlice<OpStack> {
    get {
      return self[range];
    }
  }
  
  var default_kernel: ComputeKernel {
    return { (user_sample, app_sample) in return 0.0 }
  }
  
  func evaluate(at index: Int? = nil) -> ComputeKernel {
    guard self.count > 0 else { return default_kernel }
    let target_index = index ?? self.endIndex - 1
    return evaluate_ops(self[self.startIndex ... target_index]).result
    
  }
  
  func evaluate_ops(_ ops: ArraySlice<OpStack>) -> (result: ComputeKernel, remaining_ops: ArraySlice<OpStack>) {
    return (default_kernel, [])
  }

  func tokenize() -> CFTree? {
    // In the UI, you transform this tree into your NSOutline nodes.
    // @TODO: use CFTreeCreate and the Swift pointer API to return a nested tree.
    return nil
  }
  
  
  // Reference implementation from LiquidHex.
  
//  func reduced(at index: Int? = nil) -> StreamFunction? {
//    guard self.count > 0 else { return nil }
//    let target_index = index ?? self.endIndex - 1
//    return reduce_stream(self[self.startIndex ... target_index]).result
//  }
//
//  private func reduce_stream(_ ops: ArraySlice<ZoneOp>) -> (result: StreamFunction?, remainingOps: ArraySlice<ZoneOp>) {
//    guard ops.count > 0 else { return (nil, ops) }
//    let current_index = ops.endIndex - 1
//    let op = ops[current_index]
//    let new_slice = self[self.startIndex..<current_index]
//
//    switch op {
//
//      // Selection zone is converted to a value matrix; we return a function
//      // that returns that value matrix.  Since the value of the selection zone
//    // is constant, it ignores all parameters.
//    case .EnterZone(let zone):
//      // Just return a function that returns the zone.
//      // All StreamFunction parameters are ignored.
//      let valuePickingFunction: StreamFunction = { elapsed, xCycle, yCycle in
//
//        // @TODO: this is a shame: the visualizer converts its coords into cycles (radians),
//        // but then some zones/streams need to convert it back to Ints.  Lots of work.
//        let x_coord = cycle_to_index(xCycle, dimension: zone.width)
//        let y_coord = cycle_to_index(yCycle, dimension: zone.height)
//
//        return zone[x_coord, y_coord] ? 1.0 : 0.0
//      }
//      return (valuePickingFunction, new_slice)
//
//    case .EnterStream(let value):
//      return (value.Stream, new_slice)
//
//    case .Add:
//      let (firstStream, opsAfterFirstBuild) = reduce_stream(new_slice)
//      guard let gen1 = firstStream else { return (nil, opsAfterFirstBuild) }
//
//      let (secondStream, opsAfterSecondBuild) = reduce_stream(opsAfterFirstBuild)
//      guard let gen2 = secondStream else { return (nil, opsAfterSecondBuild) }
//
//      let combinedFunction: StreamFunction = { elapsed, xCycle, yCycle in
//        return gen1(elapsed, xCycle, yCycle) + gen2(elapsed, xCycle, yCycle)
//      }
//
//      return (combinedFunction, opsAfterSecondBuild)
//
//    // Multiply takes two operands: first the parent, then its child.
//    case .Multiply:
//      let (firstStream, opsAfterFirstBuild) = reduce_stream(new_slice)
//      guard let gen1 = firstStream else { return (nil, opsAfterFirstBuild) }
//
//      let (secondStream, opsAfterSecondBuild) = reduce_stream(opsAfterFirstBuild)
//      guard let gen2 = secondStream else { return (nil, opsAfterSecondBuild) }
//
//      let combinedFunction: StreamFunction = { elapsed, xCycle, yCycle in
//        return gen1(elapsed, xCycle, yCycle) * gen2(elapsed, xCycle, yCycle)
//      }
//
//      return (combinedFunction, opsAfterSecondBuild)
//
//    case .NOp: return reduce_stream(new_slice)
//    default: return reduce_stream(new_slice)
//    }
//  }
}
