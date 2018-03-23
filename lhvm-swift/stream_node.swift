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
  
  typealias Predicate = (_ node: StreamNode, _ depth: Int, _ sibling_index: Int, _ siblings: [StreamNode]) -> Bool
  typealias SimplePredicate = (_ node: StreamNode) -> Bool
  
  // When mapping the tree into a new tree structure, we need to pass the current parent
  // (transformed to the new type) down to the children, so they they can attach a
  // reference to it.
  typealias TreeTransform<T> = (_ node: StreamNode, _ depth: Int, _ sibling_index: Int, _ siblings: [StreamNode], _ parent: T?) -> T
  
  
  // @Swift: the overloaded simple versions don't work, with trailing closure syntax
  // OR unnamed parameter syntax, because Swift can't distinguish Predicate from
  // SimplePredicate, unless it is supplied as a specific argument value.
  
  func every(predicate: @escaping Predicate) -> Bool {
    var recursive_predicate: Predicate! // needed for inline recursive closure.
    recursive_predicate = { node, depth, index, siblings in
      // If this node doesn't even pass the test, all bets are off.
      guard predicate(node, depth, index, siblings) else { return false }
      // If this node passes the test, and has no descendants, then we're good.
      guard node.children.count > 0 else { return true }
      // Otherwise, check that the children also pass the same test, and their children.
      return node.children.enumerated().reduce(true, { current_result, enumerated_child in
        let (sibling_index, child_node) = enumerated_child
        let result = recursive_predicate(child_node, depth + 1, sibling_index, node.children)
        // FALSE values in any child will bubble up and override any false values.
        return current_result ? result : false
      })
    }
    
    return recursive_predicate(self, 1, 0, [])
  }
  func every(predicate: @escaping SimplePredicate) -> Bool {
    let bound: Predicate = { node, _, _, _ in return predicate(node) }
    return self.every(predicate: bound)
  }
  
  func some(predicate: @escaping Predicate) -> Bool {
    var recursive_predicate: Predicate! // needed for inline recursive closure.
    recursive_predicate = { node, depth, index, siblings in
      if predicate(node, depth, index, siblings) { return true }
      guard node.children.count > 0 else { return false }
      return node.children.enumerated().reduce(false, { current_result, enumerated_child in
        let (sibling_index, child_node) = enumerated_child
        let result = recursive_predicate(child_node, depth + 1, sibling_index, node.children)
        // TRUE values in any child will bubble up and override any false values.
        return current_result ? true : result
      })
    }
    
    return recursive_predicate(self, 1, 0, [])
  }
  func some(predicate: @escaping SimplePredicate) -> Bool {
    let bound: Predicate = { node, _, _, _ in return predicate(node) }
    return self.some(predicate: bound)
  }
}
