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
    j = x * Float::reinterpret_from_int(0x3f22f983) +
      Float::reinterpret_from_int(0x4b40_0000)
    j = Float::from_int(j.reinterpret_as_int() - 0x4b40_0000)
    r = x - j * Float::reinterpret_from_int(0x3fc90f80)
    r = r - j * Float::reinterpret_from_int(0x37354440)
    r = r - j * Float::reinterpret_from_int(0x2c34611a)
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
  let (h, l) = mul(ix, lo)
  let plo = phi + l
  let phi = h + (plo < l).to_uint()
  let (h, l) = mul(ix, mi)
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
  if !xispos {
    r = r ^ 0x8000_0000
    q = -q
  }
  let r = Float::reinterpret_from_uint(r)
  return (r, q)
}
