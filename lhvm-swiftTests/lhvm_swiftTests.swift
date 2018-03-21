/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import XCTest
@testable import lhvm_swift

class lhvm_swiftTests: XCTestCase {
  
  func test_empty_stack_returns_nil() {
    let sampler = LHVM<HeightmapState, Double>(ops:[])
    let result = sampler.sample(at: HeightmapState(1.0, 1.0))
    XCTAssertNil(result)
  }

  func test_empty_stack_returns_empty_set() {
    let sampler = LHVM<HeightmapState, Double>(ops:[])
    let sample_result = sampler.sample(buffer: [
      HeightmapState(1.0, 2.0),
      HeightmapState(2.0, 3.0),
      HeightmapState(4.0, 5.0)
    ])
    
    XCTAssertEqual(sample_result.flatMap({ $0 }), [])
  }
  
  func test_constant_stack_returns_value() {
    let sampler = LHVM<HeightmapState, Double>(ops: [
      .input(Number(5.0))
    ])
    let sample_result = sampler.sample(at: HeightmapState(0.0, 0.0))
    XCTAssertNotNil(sample_result)
    XCTAssertEqual(sample_result!, 5.0)
  }
  
  func test_scale_ten_returns_multiplied_result() {
    let sampler = LHVM<HeightmapState, Double>(ops: [
      .input(Number(10.0)),
      .map(ScaleTen())
    ])
    let sample_result = sampler.sample(at: HeightmapState(0.0, 0.0))
    XCTAssertNotNil(sample_result)
    XCTAssertEqual(sample_result!, 100.0)
  }
  
  func test_sine_return_correct_sine_even_after_mutation_without_reevluation() {
    let the_number = Number(0.0175)
    let sampler = LHVM<HeightmapState, Double>(ops: [
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
    let sampler = LHVM<HeightmapState, Double>(ops: [
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
    let sampler = LHVM<HeightmapState, Double>(ops: [
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
    let sampler = LHVM<HeightmapState, Double>(ops: [
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
  
  func test_unininitialized_appkit_sample() {
    let sampler = LHVM<HeightmapState, Double>(ops: [
      .sample(ElapsedTime())
    ])
    let sample_result = sampler.sample(at: HeightmapState(0.0, 0.0))
    XCTAssertNotNil(sample_result)
    XCTAssertEqual(sample_result!, 0.0)
  }
  
  func test_heightmap_sample_returns_cycle() {
    // @TODO: how do we deal with sampling the schema sample?  Is the schema sample different
    // from the schema index?
//    let sampler = LHVM<HeightmapSample, Double>(ops: [
//      .sample(StateValue(\HeightmapSample.0 as! Double)) <-- Doesn't work.
//    ])
    // @TODO: attach heighmap state
    // @TODO: ask for a sample at a known cycle point.
    // @TODO: check the value of the sample matches expected.
    XCTAssert(false)
  }
  
  func test_lhvm_subscript() {
    // @TODO: do the same test as above, but use our custom subscript.
    XCTAssert(false)
  }
}
