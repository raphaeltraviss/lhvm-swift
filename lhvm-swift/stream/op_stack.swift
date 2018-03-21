/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation


// An individual stream operation is valid only for a certain platform sample
// type, a certain schema, and a certain currency.
// The StreamStack can, optionally, take the three generic type, and restrict
// everything inside of its stack to be of the same type--then you could embed
// StreamStacks within StreamStacks.
enum StreamOp<PlatformSample, SchemaSample, Currency>{
  case input(Constant<Currency>)
  case sample(StateValue<PlatformSample, SchemaSample, Currency>)
  case map(TransformOne<Currency>)
  case combine(TransformTwo<Currency>)
  case bind(StreamParameter)
}
