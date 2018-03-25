/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import XCTest
@testable import lhvm_swift

class test_stream_node: XCTestCase {
  
  func test_some_and_every() {
    let sampler = MacLhvm<HeightmapState, Double>(ops: [
      .sample(CycleX()),
      .sample(CycleY()),
      .combine(Multiply()), // Expected zero at this point.
      .input(Constant(10.0)),
      .combine(Add())
    ])
    
    guard let token_tree = sampler.tokenize() else { XCTFail(); return }
    
    let known_false = token_tree.some(predicate: { node in return false })
    let known_true = token_tree.every(predicate: { node in return true })
    XCTAssertFalse(known_false)
    XCTAssertTrue(known_true)
    
    let does_contain_sample = token_tree.some(predicate: { node, _, _, _ in
      if case .sample = node.op { return true }
      return false
    })
    let contains_all_samples = token_tree.every(predicate: { node, _, _, _ in
      if case .sample = node.op { return true }
      return false
    })
    XCTAssertTrue(does_contain_sample)
    XCTAssertFalse(contains_all_samples)
    
    let does_contain_map = token_tree.some(predicate: { node, _, _, _ in
      if case .map = node.op { return true }
      return false
    })
    let contains_no_maps = token_tree.every(predicate: { node in
      if case .map = node.op { return false }
      return true
    })
    XCTAssertFalse(does_contain_map)
    XCTAssertTrue(contains_no_maps)
  }
  
  func test_op_indices() {
    var ops: [StreamOp<AppKitSample<Double>, HeightmapState<Double>, Double>] = [
      .input(Constant<Double>(0.0)),
      .input(Constant<Double>(1.0)),
      .input(Constant<Double>(2.0)),
      .input(Constant<Double>(3.0)),
      .input(Constant<Double>(4.0)),
      .combine(Add()),
      .combine(Add()),
      .combine(Add()),
      .combine(Add())
    ]
    let sampler: MacLhvm<HeightmapState<Double>, Double> = MacLhvm<HeightmapState<Double>, Double>(ops: ops)
    
    guard let token_tree = sampler.tokenize() else { XCTFail(); return }
    
    guard let (node_8, stack_8) = token_tree.find(predicate: { node in node.stack_index == 8 }),
    let (node_7, stack_7) = token_tree.find(predicate: { node in node.stack_index == 7 }),
    let (node_4, stack_4) = token_tree.find(predicate: { node in node.stack_index == 4 }),
    let (node_0, stack_0) = token_tree.find(predicate: { node in node.stack_index == 0 })
    
    
    else { XCTFail(); return }

    // Check the index, op, and call stack for the first-processed op (at index 8).
    XCTAssertTrue(node_8.stack_index == 8)
    // @Swift: the following doesn't work, because if-case is not a normal expression.
    // XCTAssertTrue(case .combine == node_8)
    if case .combine  = node_8.op { XCTAssertTrue(true) } else { XCTFail() }
    XCTAssertTrue(stack_8.count == 0)
    
    // Check the second-processed op.
    XCTAssertTrue(node_7.stack_index == 7)
    if case .combine  = node_7.op { XCTAssertTrue(true) } else { XCTFail() }
    XCTAssertTrue(stack_7.count == 1)
    
    // Check an op buried in the call stack.
    XCTAssertTrue(node_4.stack_index == 4)
    if case .input  = node_4.op { XCTAssertTrue(true) } else { XCTFail() }
    XCTAssertTrue(stack_4.count == 4)
    
    // Check an op deep in the opstack, but shallow on the call stack.
    XCTAssertTrue(node_0.stack_index == 0)
    if case .input  = node_0.op { XCTAssertTrue(true) } else { XCTFail() }
    XCTAssertTrue(stack_0.count == 1) // Tricky!  Op 1 is called in Op 8's search.
    
    // Check that a found op's parent, and the fist item in its call stack, are equal.
    XCTAssertTrue(node_4.parent!.stack_index == stack_4[0].stack_index)
  }
  
}
