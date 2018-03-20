import XCTest
@testable import lhvm_swift

class lhvm_swiftTests: XCTestCase {
  
  func test_empty_stack_returns_nil() {
    let sampler = LHVM<HeightmapSample, Double>(ops:[])
    let result = sampler.sample(at: (1.0, 1.0))
    XCTAssertNil(result)
  }

  func test_empty_stack_returns_empty_set() {
    let sampler = LHVM<HeightmapSample, Double>(ops:[])
    let sample_result = sampler.sample(buffer: [(1,2), (2,3), (4,5)])
    
    XCTAssertEqual(sample_result.flatMap({ $0 }), [])
  }
  
  func test_constant_stack_returns_value() {
    let sampler = LHVM<HeightmapSample, Double>(ops: [
      .input(ConstantValue(5.0))
    ])
    let sample_result = sampler.sample(at: (0.0, 0.0))
    XCTAssertNotNil(sample_result)
    XCTAssertEqual(sample_result!, 5.0)
  }
  
  func test_scale_ten_returns_multiplied_result() {
    let sampler = LHVM<HeightmapSample, Double>(ops: [
      .input(ConstantValue(10.0)),
      .map(UnaryTransform<Double>(.scale_ten, parameters: [StreamParameter]()))
    ])
    let sample_result = sampler.sample(at: (0.0, 0.0))
    XCTAssertNotNil(sample_result)
    XCTAssertEqual(sample_result!, 100.0)
  }
  
  func test_sine_return_correct_sine_even_after_mutation_without_reevluation() {
    let the_constant = ConstantValue(0.0175)
    let sampler = LHVM<HeightmapSample, Double>(ops: [
      .input(the_constant),
      .map(UnaryTransform<Double>(.simple_sine, parameters: [StreamParameter]()))
    ])
    
    let sample_result = sampler.sample(at: (0.0, 0.0))
    XCTAssertNotNil(sample_result)
    
    let delta1 = abs(sample_result! - 0.0175) // value from sine table
    XCTAssert(delta1 < 0.001)
    
    the_constant.state.value = 0.5236
    let sample_result2 = sampler.sample(at: (0.0, 0.0))
    XCTAssertNotNil(sample_result2)
    let delta2 = abs(sample_result2! - 0.5) // value from sine table
    XCTAssert(delta2 < 0.001)
  }
  
  func test_order_of_operations_determined_by_order_on_the_stack() {
    let sampler = LHVM<HeightmapSample, Double>(ops: [
      .input(ConstantValue(0.0175)),
      .map(UnaryTransform<Double>(.simple_sine, parameters: [StreamParameter]())),
      .map(UnaryTransform<Double>(.scale_ten, parameters: [StreamParameter]())),
      .map(UnaryTransform<Double>(.scale_ten, parameters: [StreamParameter]()))
    ])
    
    let sample_result = sampler.sample(at: (0.0, 0.0))
    XCTAssertNotNil(sample_result)
    let delta1 = abs(sample_result! - 001.75) // value from sine table
    XCTAssert(delta1 < 0.001)
  }
  
  func test_basic_combinator() {
    let sampler = LHVM<HeightmapSample, Double>(ops: [
      .input(ConstantValue(0.3)),
      .input(ConstantValue(0.3)),
      .combine(BinaryTransform<Double>(.add, parameters: [StreamParameter]()))
    ])
    
    let actual = sampler.sample(at: (0.0, 0.0))
    XCTAssertNotNil(actual)
    let expected = 0.6
    XCTAssert(abs(actual! - expected) < 0.001)
  }
  
  func test_combinator_in_a_stack() {
    let sampler = LHVM<HeightmapSample, Double>(ops: [
      .input(ConstantValue(0.3)),
      .input(ConstantValue(0.3)),
      .combine(BinaryTransform<Double>(.add, parameters: [StreamParameter]())),
      .map(UnaryTransform<Double>(.simple_sine, parameters: [StreamParameter]())), //0.565 sine table
      .input(ConstantValue(10.0)),
      .combine(BinaryTransform<Double>(.multiply, parameters: [StreamParameter]()))
    ])
    
    let actual = sampler.sample(at: (0.0, 0.0))
    XCTAssertNotNil(actual)
    let expected = sin(0.3 + 0.3) * 10.0
    XCTAssert(abs(actual! - expected) < 0.001)
  }
}
