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
  
}
