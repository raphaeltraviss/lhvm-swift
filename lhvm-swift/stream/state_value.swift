/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

// @Swift: class only exists to work around limitations in protocols with
// associated types.  Not meant to be instantiated.
public class StateValue<PlatformSample, SchemaSample, Currency> : StateStream {
  public typealias UserSample = PlatformSample
  public typealias SampleIndex = SchemaSample
  public typealias SampleOutput = Currency
  
  public var reduce: (_ platform_sample: PlatformSample, _ schema_sample: SchemaSample) -> Currency
  
  public init(_ platform_property: KeyPath<PlatformSample, Currency>) {
    self.reduce = { platform, _ in
      return platform[keyPath: platform_property]
    }
  }
  public init(_ schema_property: KeyPath<SchemaSample, Currency>) {
    self.reduce = { _, schema in
      return schema[keyPath: schema_property]
    }
  }
  
  public init(swift_workaround: Int) { self.reduce = { _, _ in return 1.0 as! Currency } }
}



public final class ElapsedTime: StateValue<AppKitSample<Double>, HeightmapState<Double>, Double> {
  let property: KeyPath<AppKitSample<Double>, Double> = \AppKitSample<Double>.time_elapsed!
  public init() { super.init(property) }
}
public final class MouseX: StateValue<AppKitSample<Double>, HeightmapState<Double>, Double> {
  public init() {
    super.init(swift_workaround: 55)
    self.reduce = { platform, _ in return Double(platform.mouse_x) }
  }
}
public final class MouseY: StateValue<AppKitSample<Double>, HeightmapState<Double>, Double> {
  public init() {
    super.init(swift_workaround: 55)
    self.reduce = { platform, _ in return Double(platform.mouse_y) }
  }
}
public final class CycleX: StateValue<AppKitSample<Double>, HeightmapState<Double>, Double> {
  public init() { super.init(\HeightmapState.x) }
}
public final class CycleY: StateValue<AppKitSample<Double>, HeightmapState<Double>, Double> {
  public init() { super.init(\HeightmapState.y) }
}



public final class GraphicsTime: StateValue<AppKitSample<CGFloat>, HeightmapState<CGFloat>, CGFloat> {
  let property: KeyPath<AppKitSample<CGFloat>, CGFloat> = \AppKitSample<CGFloat>.time_elapsed!
  public init() { super.init(property) }
}
public final class GraphicsMouseX: StateValue<AppKitSample<CGFloat>, HeightmapState<CGFloat>, CGFloat> {
  public init() {
    super.init(swift_workaround: 55)
    self.reduce = { platform, _ in return CGFloat(platform.mouse_x) }
  }
}
public final class GraphicsMouseY: StateValue<AppKitSample<CGFloat>, HeightmapState<CGFloat>, CGFloat> {
  public init() {
    super.init(swift_workaround: 55)
    self.reduce = { platform, _ in return CGFloat(platform.mouse_y) }
  }
}
public final class GraphicsCycleX: StateValue<AppKitSample<CGFloat>, HeightmapState<CGFloat>, CGFloat> {
  public init() { super.init(\HeightmapState.x) }
}
public final class GraphicsCycleY: StateValue<AppKitSample<CGFloat>, HeightmapState<CGFloat>, CGFloat> {
  public init() { super.init(\HeightmapState.y) }
}
