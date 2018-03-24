/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

public protocol ValueStream {
  associatedtype Currency
  var reduce: () -> Currency { get }
}

public protocol StateStream {
  associatedtype UserSample
  associatedtype SampleIndex
  associatedtype SampleOutput
  var reduce: (UserSample, SampleIndex) -> SampleOutput { get }
}

public protocol TransformStream {
  associatedtype SampleOutput
  var reduce: (SampleOutput) -> SampleOutput { get }
}

public protocol MergeStream {
  associatedtype SampleOutput
  var reduce: (SampleOutput, SampleOutput) -> SampleOutput { get }
}
