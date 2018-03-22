/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation

class StreamNode<ConcreteOpType> {
  var op: ConcreteOpType
  
  weak var parent: StreamNode?
  var children = [StreamNode<ConcreteOpType>]()
  
  init(_ op: ConcreteOpType) { self.op = op }
  
  convenience init(_ op: ConcreteOpType, parent_node: StreamNode) {
    self.init(op)
    self.parent = parent_node
  }
  
  convenience init(_ op: ConcreteOpType, child_ops: [ConcreteOpType]) {
    self.init(op)
    let child_nodes = child_ops.map({ StreamNode($0) })
    for node in child_nodes {
      node.parent = self
    }
    self.children = child_nodes
  }
  
  convenience init(_ op: ConcreteOpType, child_nodes: [StreamNode]) {
    self.init(op)
    for node in child_nodes {
      node.parent = self
    }
    self.children = child_nodes
  }
  
  func append_child(_ node: StreamNode<ConcreteOpType>) {
    children.append(node)
    node.parent = self
  }
}
