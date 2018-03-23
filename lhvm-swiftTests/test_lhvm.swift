/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import XCTest
@testable import lhvm_swift

class lhvm_swiftTests: XCTestCase {
  
  func test_empty_stack_returns_nil() {
    let sampler = MacLhvm<HeightmapState, Double>(ops:[])
    let result = sampler.sample(at: HeightmapState(1.0, 1.0))
    XCTAssertNil(result)
  }

  func test_empty_stack_returns_empty_set() {
    let sampler = MacLhvm<HeightmapState, Double>(ops:[])
    let sample_result = sampler.sample(buffer: [
      HeightmapState(1.0, 2.0),
      HeightmapState(2.0, 3.0),
      HeightmapState(4.0, 5.0)
    ])
    
    XCTAssertEqual(sample_result.flatMap({ $0 }), [])
  }
  
  func test_constant_stack_returns_value() {
    let sampler = MacLhvm<HeightmapState, Double>(ops: [
      .input(Number(5.0))
    ])
    let sample_result = sampler.sample(at: HeightmapState(0.0, 0.0))
    XCTAssertNotNil(sample_result)
    XCTAssertEqual(sample_result!, 5.0)
  }
  
  func test_scale_ten_returns_multiplied_result() {
    let sampler = MacLhvm<HeightmapState, Double>(ops: [
      .input(Number(10.0)),
      .map(ScaleTen())
    ])
    let sample_result = sampler.sample(at: HeightmapState(0.0, 0.0))
    XCTAssertNotNil(sample_result)
    XCTAssertEqual(sample_result!, 100.0)
  }
  
  func test_sine_return_correct_sine_even_after_mutation_without_reevluation() {
    let the_number = Number(0.0175)
    let sampler = MacLhvm<HeightmapState, Double>(ops: [
      .input(the_number),
      .map(SimpleSine())
    ])
    
    let sample_result = sampler.sample(at: HeightmapState(0.0, 0.0))
    XCTAssertNotNil(sample_result)
    
    let delta1 = abs(sample_result! - 0.0175) // value from sine table
    XCTAssert(delta1 < 0.001)
    
    the_number.value = 0.5236
    let sample_result2 = sampler.sample(at: HeightmapState(0.0, 0.0))
    XCTAssertNotNil(sample_result2)
    let delta2 = abs(sample_result2! - 0.5) // value from sine table
    XCTAssert(delta2 < 0.001)
  }
  
  func test_order_of_operations_determined_by_order_on_the_stack() {
    let sampler = MacLhvm<HeightmapState, Double>(ops: [
      .input(Number(0.0175)),
      .map(SimpleSine()),
      .map(ScaleTen()),
      .map(ScaleTen())
    ])
    
    let sample_result = sampler.sample(at: HeightmapState(0.0, 0.0))
    XCTAssertNotNil(sample_result)
    let delta1 = abs(sample_result! - 001.75) // value from sine table
    XCTAssert(delta1 < 0.001)
  }
  
  func test_basic_combinator() {
    let sampler = MacLhvm<HeightmapState, Double>(ops: [
      .input(Constant(0.3)),
      .input(Constant(0.3)),
      .combine(Add())
    ])
    
    let actual = sampler.sample(at: HeightmapState(0.0, 0.0))
    XCTAssertNotNil(actual)
    let expected = 0.6
    XCTAssert(abs(actual! - expected) < 0.001)
  }
  
  func test_combinator_in_a_stack() {
    let sampler = MacLhvm<HeightmapState, Double>(ops: [
      .input(Number(0.3)),
      .input(Number(0.3)),
      .combine(Add()),
      .map(SimpleSine()), // sin(0.6) = 0.565, from sine table
      .input(Number(10.0)),
      .combine(Multiply())
    ])
    
    let actual = sampler.sample(at: HeightmapState(0.0, 0.0))
    XCTAssertNotNil(actual)
    let expected = sin(0.3 + 0.3) * 10.0
    XCTAssert(abs(actual! - expected) < 0.001)
  }
  
  func test_heightmap_sample_returns_cycle() {
    let sampler = MacLhvm<HeightmapState, Double>(ops: [
      .sample(CycleX())
    ])
    guard let result = sampler.sample(at: HeightmapState(7.0, 10.0)) else { XCTFail(); return }
    XCTAssertEqual(result, 7.0)
  }
  
  func test_heightmap_sample_transform() {
    let sampler = MacLhvm<HeightmapState, Double>(ops: [
      .sample(CycleX()),
      .sample(CycleY()),
      .combine(Add()),
      .map(ScaleTen())
    ])
    guard let result1 = sampler.sample(at: HeightmapState(5.0, 5.0)) else { XCTFail(); return }
    guard let result2 = sampler.sample(at: HeightmapState(50.0, 50.0)) else { XCTFail(); return }
    XCTAssertEqual(result1, 100.0)
    XCTAssertEqual(result2, 1000.0)
  }
  
  func test_lhvm_subscript() {
    let sampler = MacLhvm<HeightmapState, Double>(ops: [
      .sample(CycleX()),
      .sample(CycleY()),
      .combine(Multiply())
    ])
    guard let result1 = sampler[5.0, 10.0] else { XCTFail(); return }
    guard let result2 = sampler[6.0, 7.0] else { XCTFail(); return }
    XCTAssertEqual(result1, 50.0)
    XCTAssertEqual(result2, 42.0)
  }
  
  func test_appkit_default_sample() {
    let sampler = MacLhvm<HeightmapState, Double>(ops: [
      .sample(MouseX()),
      .sample(MouseY()),
      .combine(Multiply()), // Expected zero at this point.
      .input(Constant(10.0)),
      .combine(Add())
    ])
    
    // We're not sampling HeightmapState, so both of these should be equivalent.
    guard let result1 = sampler[533.0, 12220.0] else { XCTFail(); return }
    guard let result2 = sampler[2.234, 0.00023] else { XCTFail(); return }
    XCTAssertEqual(result1, 10.0)
    XCTAssertEqual(result2, 10.0)
  }
  
  func test_appkit_bogus_ui_sample() {
    let sampler = MacLhvm<HeightmapState, Double>(ops: [
      .sample(MouseX()),
      .sample(MouseY()),
      .combine(Multiply()), // Expected zero at this point.
      .input(Constant(10.0)),
      .combine(Add())
    ])
    
    // We're not sampling HeightmapState, so both of these should be equivalent.
    guard let result1 = sampler[533.0, 12220.0] else { XCTFail(); return }
    guard let result2 = sampler[2.234, 0.00023] else { XCTFail(); return }
    XCTAssertEqual(result1, 10.0)
    XCTAssertEqual(result2, 10.0)
  }
  
  func test_elapsed_time_increases() {
    let sampler = MacLhvm<HeightmapState, Double>(ops: [
      .sample(ElapsedTime())
    ])
    
    guard let result1 = sampler[0.0, 0.0] else { XCTFail(); return }
    Thread.sleep(forTimeInterval: 0.100)
    guard let result2 = sampler[0.0, 0.0] else { XCTFail(); return }
    XCTAssertTrue(result2 >= result1 + 0.100)
    
    Thread.sleep(forTimeInterval: 0.100)
    guard let result3 = sampler[0.0, 0.0] else { XCTFail(); return }
    
    XCTAssertTrue(result3 >= result2 + 0.100)
  }
  
  func test_tree_generation() {
    let sampler = MacLhvm<HeightmapState, Double>(ops: [
      .sample(CycleX()),
      .sample(CycleY()),
      .combine(Multiply()), // Expected zero at this point.
      .input(Constant(10.0)),
      .combine(Add())
    ])
    
    guard let token_tree = sampler.tokenize() else { XCTFail(); return }
    let contains_a_map = token_tree.some(predicate: { node in
      if case .map = node.op { return true }
      return false
    })
    let does_not_contain_map = token_tree.every(predicate: { node in
      if case .map = node.op { return false }
      return true
    })
    
    XCTAssertFalse(contains_a_map)
    XCTAssertTrue(does_not_contain_map)
    
    // Search for an add node: it should find the .combine at index 4.
    guard let (add_node, _) = token_tree.find(predicate: { node in
      if case .combine = node.op { return true }
      return false
    }) else { XCTFail(); return }
    XCTAssertTrue(add_node.stack_index == 4)
    
    // Search for the first node on the stack--its parent should be the
    // .combine Multiply at index 2.
    guard let (first_on_stack, call_stack) = token_tree.find(predicate: { node in
      return node.stack_index == 0
    }) else { XCTFail(); return }
    XCTAssertNotNil(first_on_stack.parent)
    XCTAssertTrue(first_on_stack.parent!.stack_index == call_stack[0].stack_index)
  }
}





