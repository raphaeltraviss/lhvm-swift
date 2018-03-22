/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import XCTest
@testable import lhvm_swift

class test_stream_node: XCTestCase {
  func test_empty_stack_returns_empty_set() {
    let sampler = MacLhvm<HeightmapState, Double>(ops: [
      .sample(CycleX()),
      .sample(CycleY()),
      .combine(Multiply()), // Expected zero at this point.
      .input(Constant(10.0)),
      .combine(Add())
      ])
    
    let token_tree = sampler.tokenize()
    // @TODO: test the .some, .every, .map, and .flatMap methods actually work.
  }
}
