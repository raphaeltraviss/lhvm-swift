import XCTest
@testable import lhvm_swift

class lhvm_swiftTests: XCTestCase {
  
  private let sampler = LHVM<(Int, Int), Double>()
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testSampleReturnsFive() {
    let sample_result = sampler.sample(at: (1,1))
    XCTAssertEqual(sample_result, 5.0)
  }
  
  func test_sample_buffer_returns_array() {
    let sample_result = sampler.sample(buffer: [(1,2), (2,3), (4,5)])
    XCTAssertEqual(sample_result, [5.0, 5.0, 5.0])
  }
  
  // @TODO: finish
  func test_constant_creation() {
    let params: [StreamParameter] = [.constant(2.0), .amplitude(2.0), .wavelength(3.4), .phase_shift(3.3)]
    let expected_state = ConstantState(constant: 2.0)
    let stream = Constant(parameters: params)
    XCTAssertEqual(expected_state.constant, stream.state.constant)
  }
  
  func test_time_receptor_creation() {
    let params: [StreamParameter] = [.speed(1.0), .loop_count(5), .duration(2.0), .interval(1.0)]
    let expected_state = TimeReceptorState(speed: 1.0, loop_count: 5, duration: 2.0, interval: 1.0)
    let stream = TimeReceptor(parameters: params)
    XCTAssertEqual(expected_state.speed, stream.state.speed)
    XCTAssertEqual(expected_state.loop_count, stream.state.loop_count)
    XCTAssertEqual(expected_state.duration, stream.state.duration)
    XCTAssertEqual(expected_state.interval, stream.state.interval)
  }
  
  func test_lhvm_sample_returns_two() {
    let sampler = LHVM<(Int, Int), Double>()
    sampler.load_program()
    let sample_1 = sampler.sample(at: (211, 2334))
    let sample_2 = sampler.sample(at: (234234, 0))
    XCTAssertEqual(sample_1, 2.0)
    XCTAssertEqual(sample_2, 2.0)
  }
  
  func testPerformanceExample() {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }
  
}
