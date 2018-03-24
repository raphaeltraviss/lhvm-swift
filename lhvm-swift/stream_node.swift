/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation

public class StreamNode<ConcreteOpType> {
  var op: ConcreteOpType
  var stack_index: Int
  
  weak var parent: StreamNode?
  var children = [StreamNode<ConcreteOpType>]()
  
  init(_ op: ConcreteOpType, at index: Int) {
    self.op = op
    self.stack_index = index
  }
  
  convenience init(_ op: ConcreteOpType, at index: Int, parent_node: StreamNode) {
    self.init(op, at: index)
    self.parent = parent_node
  }
  
  convenience init(_ op: ConcreteOpType, at index: Int, child_ops: ArraySlice<ConcreteOpType>) {
    self.init(op, at: index)
    
    // Note: we use an ArraySlice, so that we can get the original OpStack indices.
    let child_nodes: [StreamNode] = child_ops.enumerated().map({ enumeration in
      let (offset, node) = enumeration
      let original_index = child_ops.startIndex + offset
      return StreamNode(node, at: original_index)
    })
    for node in child_nodes {
      node.parent = self
    }
    self.children = child_nodes
  }
  
  convenience init(_ op: ConcreteOpType, at index: Int, child_nodes: [StreamNode]) {
    self.init(op, at: index)
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
  typealias NodeAndStack = (StreamNode, [StreamNode])
  
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
  
  // Returns the first found StreamNode that satisfies the predicate.  In addition,
  // returns an array of StreamNodes that represent the "call stack" that contains
  // the found node -- all of the functions that called out looking for operands, that
  // eventually found this one.
  func find(predicate: @escaping Predicate) -> NodeAndStack? {
    // Predicate, with call stack accumulator.
    var recursive_finder: ((
      _ node: StreamNode,
      _ depth: Int,
      _ sibling_index: Int,
      _ siblings: [StreamNode],
      _ call_stack: [StreamNode]
    ) -> NodeAndStack?)!
    
    recursive_finder = { node, depth, index, siblings, call_stack in
      if predicate(node, depth, index, siblings) { return (node, call_stack) }
      guard node.children.count > 0 else { return nil }
      let next_call_stack = [node] + call_stack
      return node.children.enumerated().reduce(nil, { current_result, enumerated_child in
        let (sibling_index, child_node) = enumerated_child
        let result = recursive_finder(child_node, depth + 1, sibling_index, node.children, next_call_stack)
        // Found SearchResult will "bubble up" the reduce.
        return current_result == nil ? result : current_result
      })
    }
    
    return recursive_finder(self, 1, 0, [], [])
  }
  func find(predicate: @escaping SimplePredicate) -> NodeAndStack? {
    let bound: Predicate = { node, _, _, _ in return predicate(node) }
    return self.find(predicate: bound)
  }
}
