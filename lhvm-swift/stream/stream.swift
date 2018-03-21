/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

protocol ValueStream {
  associatedtype Currency
  var reduce: () -> Currency { get }
}

protocol StateStream {
  associatedtype UserSample
  associatedtype SampleIndex
  associatedtype SampleOutput
  var reduce: (UserSample, SampleIndex) -> SampleOutput { get }
}

protocol TransformStream {
  associatedtype SampleOutput
  var reduce: (SampleOutput) -> SampleOutput { get }
}

protocol MergeStream {
  associatedtype SampleOutput
  var reduce: (SampleOutput, SampleOutput) -> SampleOutput { get }
}
