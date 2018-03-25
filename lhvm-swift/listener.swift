/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

public struct AppKitSample<NumberType> {
  var resolution_x: Int = 0
  var resolution_y: Int = 0
  var mouse_x: Int = 0
  var mouse_y: Int = 0
  var time_elapsed: NumberType!
  var time_delta: NumberType!
  var keys_pressed: [Int] = []
}

public class Listener<PlatformSample> {
  var report: () -> PlatformSample? = { return nil }
}


public final class AppKitListener: Listener<AppKitSample<Double>> {
  let start_time = Date()
  public override init() {
    super.init()
    self.report = {
      var the_sample = AppKitSample<Double>()
      the_sample.time_elapsed = abs(self.start_time.timeIntervalSinceNow)
      return the_sample
    }
  }
}


public final class AppKitGraphicsListener: Listener<AppKitSample<CGFloat>> {
  let start_time = Date()
  public override init() {
    super.init()
    self.report = {
      var the_sample = AppKitSample<CGFloat>()
      the_sample.time_elapsed = CGFloat(self.start_time.timeIntervalSinceNow)
      return the_sample
    }
  }
}

/*
 How do I want to use the Listener on an NSView?
 * Do I want Listener to instantiate an NSView?
 * Do I want Listener to be a protocol that your custom NSView conforms to?
 * Do I want to manually add event listeners, that update a property on Listener?
 * Do I want to generate a whole new Listener, every time a sample changes?
 * Do I want Listener to go out to its NSView, look at cached properties applied
   via its subclass, and pull the sample values when asked?  NSView conforms to
   a protocol, so Listener knows how to talk to it.
    * Does NSView have existing properties?
 * Do I need to reference a global, such as NSWindow?
 * Can we configure the mouse tracking area via MouseX state properties? Does this
   configure the Listener or NSView it eventually attaches to?
 */
