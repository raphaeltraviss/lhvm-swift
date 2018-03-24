/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Cocoa

class HeightmapView: NSView {
  
  var is_playing: Bool = false

  
  var displayLink: CVDisplayLink?
  var currentTime: CVTimeStamp = CVTimeStamp()
  
  var get_sample: ((Double, Double) -> Double?)?
  
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    
    guard let sampler = get_sample else { return }
    guard let ctx = NSGraphicsContext.current?.cgContext else { return }
    
    CVDisplayLinkGetCurrentTime(displayLink!, UnsafeMutablePointer<CVTimeStamp>(&currentTime))
    let current_time = CGFloat(currentTime.videoTime) / CGFloat(77000000.0)

    let cell_length: CGFloat = self.bounds.width / 100.0;
    let cell_height: CGFloat = self.bounds.height / 100.0;
    let total_space: CGFloat = 1000.0
    
    
    for x_index in 0..<100 {
      for y_index in 0..<100 {
        let x = CGFloat(x_index)
        let y = CGFloat(y_index)
        let pos_value = (x * y) / total_space
        let pos_time_value = sin(pos_value + current_time)
        guard let sample = sampler(Double(x), Double(y)) else { return }
        let pos_time_sample_value = x > 50.0 ? pos_time_value + CGFloat(sample): pos_time_value
        let color = CGColor(gray: pos_time_sample_value, alpha: 1.0)
        ctx.setFillColor(color)
        let rect = NSMakeRect(x * cell_length, y * cell_height, cell_length, cell_height)
        ctx.fill(rect)
      }
    }
  }
  
  func start() {
    self.is_playing = true
    // call draw.
  }
  func stop() {
    // set variable to break render loop cycle.
  
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    CVDisplayLinkCreateWithActiveCGDisplays(&displayLink)
    CVDisplayLinkSetOutputCallback(displayLink!, displayLinkOutputCallback, UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()))
    CVDisplayLinkStart(displayLink!)
  }
}

func displayLinkOutputCallback(
  displayLink: CVDisplayLink,
  _ inNow: UnsafePointer<CVTimeStamp>,
  _ inOutputTime: UnsafePointer<CVTimeStamp>,
  _ flagsIn: CVOptionFlags,
  _ flagsOut: UnsafeMutablePointer<CVOptionFlags>,
  _ displayLinkContext: UnsafeMutableRawPointer?
  ) -> CVReturn {
  let my_self = Unmanaged<NSView>.fromOpaque(displayLinkContext!).takeUnretainedValue()
  DispatchQueue.main.async { () -> Void in
    my_self.setNeedsDisplay(NSRect(x: 0.0, y: 0.0, width: my_self.bounds.width, height: my_self.bounds.height))
  }
  return kCVReturnSuccess
}
