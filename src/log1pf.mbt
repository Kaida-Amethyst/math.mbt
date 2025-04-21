///|
pub fn log1pf(x : Float) -> Float {
  let mut ui : UInt = x.reinterpret_as_uint()
  let mut f : Float = 0
  let mut c : Float = 0
  let mut iu : UInt = 0
  let one : Float = 1.0
  let two : Float = 2.0
  let ix = ui
  let mut k = 1
  if ix < 0x3ed413d0 || (ix >> 31) > 0 {
    if ix >= 0xbf800000 {
      if x == -1.0 {
        return x / 0.0
      }
      return (x - x) / 0.0
    }
    if (ix << 1) < (0x33800000U << 1) {
      // if (ix & 0x7f800000) == 0 {
      //     force_eval!(x * x);
      // }
      return x
    }
    if ix <= 0xbe95f619 {
      k = 0
      c = 0.0
      f = x
    }
  } else if ix >= 0x7f800000 {
    return x
  }
  if k > 0 {
    ui = (one + x).reinterpret_as_uint()
    iu = ui
    iu += 0x3f800000U - 0x3f3504f3U
    k = (iu >> 23).reinterpret_as_int() - 0x7f
    if k < 25 {
      let fui = ui.reinterpret_as_float()
      c = if k >= 2 { one - (fui - x) } else { x - (fui - 1.0) }
      c /= ui.reinterpret_as_float()
    } else {
      c = 0.0
    }
    iu = (iu & 0x007fffff) + 0x3f3504f3
    ui = iu
    f = ui.reinterpret_as_float() - 1.0
  }
  let s = f / (two + f)
  let z = s * s
  let w = z * z
  let t1 = w * (LG2_F + w * LG4_F)
  let t2 = z * (LG1_F + w * LG3_F)
  let r = t2 + t1
  let hfsq = (0.5 : Float) * f * f
  let dk = k.to_float()
  s * (hfsq + r) + (dk * FLOAT_LN2_LO + c) - hfsq + f + dk * FLOAT_LN2_HI
}
