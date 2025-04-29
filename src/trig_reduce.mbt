///|
const SIN_SWITCHOVER : Float = 201.15625

///|
const COS_SWITCHOVER : Float = 142.90625

///|
fn mulh(a : UInt, b : UInt) -> UInt {
  let a = a.to_uint64()
  let b = b.to_uint64()
  let res = a * b
  (res >> 32).to_uint()
}

///|
fn mul(a : UInt, b : UInt) -> (UInt, UInt) {
  let a = a.to_uint64()
  let b = b.to_uint64()
  let res = a * b
  ((res >> 32).to_uint(), res.to_uint())
}

///|
fn trig_reduce(x : Float, switch_over : Float) -> (Float, Int) {
  if x.abs() <= switch_over {
    let mut j : Float = 0.0
    let mut r : Float = 0.0
    j = x * (0x3f22f983).reinterpret_as_float() +
      (0x4b40_0000).reinterpret_as_float()
    j = (j.reinterpret_as_uint() - 0x4b40_0000).to_float()
    r = x - j * (0x3fc90f80).reinterpret_as_float()
    r = r - j * (0x37354440).reinterpret_as_float()
    r = r - j * (0x2c34611a).reinterpret_as_float()
    return (r, j.to_int())
  }
  let xispos = x > 0.0
  let mut exp : Int = ((x.reinterpret_as_int() >> 23) & 0xff) - 126
  let ix = ((x.reinterpret_as_uint() & 0x007fffff) << 8) | 0x80000000
  let ind = exp >> 5
  exp = exp & 0x1f
  let two_over_pi : Array[UInt] = [
    0x00000000, 0x28be60db, 0x9391054a, 0x7f09d5f4, 0x7d4d3770, 0x36d8a566, 0x4f10e410,
    0000000000,
  ]
  let mut hi = two_over_pi[ind]
  let mut mi = two_over_pi[ind + 1]
  let mut lo = two_over_pi[ind + 2]
  let tp = two_over_pi[ind + 3]
  if exp > 0 {
    hi = (hi << exp) | (mi >> (32 - exp))
    mi = (mi << exp) | (lo >> (32 - exp))
    lo = (lo << exp) | (tp >> (32 - exp))
  }
  let phi = 0U
  let l = ix * lo
  let h = mulh(ix, lo)
  let plo = phi + l
  let phi = h + (plo < l).to_uint()
  let l = ix * mi
  let h = mulh(ix, mi)
  let mut plo = phi + l
  let phi = h + (plo < l).to_uint()
  let l = ix * hi
  let mut phi = phi + l
  let mut q : Int = (phi >> 30).reinterpret_as_int()
  phi = phi & 0x3fffffff
  if (phi & 0x2000_0000) != 0 {
    phi = phi - 0x4000_0000
    q = q + 1
  }
  let s : UInt = phi & 0x8000_0000
  if phi >= 0x8000_0000 {
    phi = phi.lnot()
    plo = 0U - plo
    phi += (plo == 0).to_uint()
  }
  exp = 0
  while phi < 0x8000_0000 {
    phi = (phi << 1) | (plo >> 31)
    plo = plo << 1
    exp = exp - 1
  }
  phi = mulh(phi, 0xc90f_daa2)
  if phi < 0x8000_0000 {
    phi = phi << 1
    exp = exp - 1
  }
  let mut r = s +
    ((exp + 128) << 23).reinterpret_as_uint() +
    (phi >> 8) +
    ((phi & 0xff) > 0x7e).to_uint()
  if not(xispos) {
    r = r ^ 0x8000_0000
    q = -q
  }
  let r = r.reinterpret_as_float()
  return (r, q)
}

///|
fn sinf_poly(x : Float) -> Float {
  let s = x * x
  let mut r = (0x3640_5000).reinterpret_as_float()
  r = r * s - (0x3950_3486).reinterpret_as_float()
  r = r * s + (0x3c08_88c1).reinterpret_as_float()
  r = r * s - (0x3e2a_aaab).reinterpret_as_float()
  let t = x * s
  r = r * t + x
  r
}

///|
fn cosf_poly(x : Float) -> Float {
  let s = x * x
  let mut r = (0x37cd_4000).reinterpret_as_float()
  r = r * s - (0x3ab6_077d).reinterpret_as_float()
  r = r * s + (0x3d2a_aaa8).reinterpret_as_float()
  r = r * s - (0x3f00_0000).reinterpret_as_float()
  r = r * s + (0x3f80_0000).reinterpret_as_float()
  r
}

///|
fn sin_cos_core(x : Float, q : Int) -> Float {
  let mut r = if (q & 1) != 0 { cosf_poly(x) } else { sinf_poly(x) }
  if (q & 2) != 0 {
    r = -r
  }
  r
}
