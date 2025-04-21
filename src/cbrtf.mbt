///| Cube root (Float)
///
/// Computes the cube root of the argument.
pub fn cbrtf(x : Float) -> Float {
  let b1 : UInt = 709958130 // B1 = (127-127.0/3-0.03306235651)*2**23 */
  let b2 : UInt = 642849266 // B2 = (127-127.0/3-24/3-0.03306235651)*2**23 */
  let mut r : Double = 0.0
  let mut t : Double = 0.0
  let mut ui : UInt = x.reinterpret_as_uint()
  let mut hx : UInt = ui & 0x7fffffff
  if hx >= 0x7f800000 {
    // cbrt(NaN,INF) is itself
    return x + x
  }

  // rough cbrt to 5 bits
  if hx < 0x00800000 {
    // zero or subnormal?
    if hx == 0 {
      return x
    } // cbrt(+-0) is itself
    ui = (x * (0x1.0p24 : Float)).reinterpret_as_uint()
    hx = ui & 0x7fffffff
    hx = hx / 3 + b2
  } else {
    hx = hx / 3 + b1
  }
  ui = ui & 0x80000000
  ui = ui | hx

  //
  // First step Newton iteration (solving t*t-x/t == 0) to 16 bits.  In
  // double precision so that its terms can be arranged for efficiency
  // without causing overflow or underflow.
  //
  t = ui.reinterpret_as_float().to_double()
  r = t * t * t
  t = t * (x.to_double() + x.to_double() + r) / (x.to_double() + r + r)

  //
  // Second step Newton iteration to 47 bits.  In double precision for
  // efficiency and accuracy.
  //
  r = t * t * t
  t = t * (x.to_double() + x.to_double() + r) / (x.to_double() + r + r)

  // rounding to 24 bits is perfect in round-to-nearest mode
  t.to_float()
}
