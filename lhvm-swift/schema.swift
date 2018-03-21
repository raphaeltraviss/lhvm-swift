// @Swift: implementing the schema sample as a struct, because tuples do
// no work with KeyPath.  Once KeyPath works with tuples, then we can change
// this to a (Double, Double).
struct HeightmapState {
  var x: Double
  var y: Double
  init(_ x: Double, _ y: Double) {
    self.x = x
    self.y = y
  }
}
