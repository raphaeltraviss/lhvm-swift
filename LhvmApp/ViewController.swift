/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Cocoa
import lhvm_swift

class ViewController: NSViewController {
  typealias Sampler = Lhvm<AppKitSample, HeightmapState, Double>
  
  var sampler: Lhvm<AppKitSample, HeightmapState, Double>!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    guard let heightmap = self.view as? HeightmapView else { return }
  
    let ops = Sampler.OpStack([
      .sample(ElapsedTime()),
      .map(SimpleSine())
    ])
    
    self.sampler = Sampler(ops: ops)
    self.sampler.platform_listener = AppKitListener()
    heightmap.get_sample = { x, y in return self.sampler[x, y] }
    
    
    // Do any additional setup after loading the view.
  }

  override var representedObject: Any? {
    didSet {
    // Update the view, if already loaded.
    }
  }


}

