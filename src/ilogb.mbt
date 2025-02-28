///| ilogb(x) returns the binary exponent of non-zero x
pub fn ilogb(x : Double) -> Int {
  let mut hx : Int = __hi(x).reinterpret_as_int() & 0x7fffffff
  if hx < 0x00100000 {
    let mut lx : Int = __low(x).reinterpret_as_int()
    if x == 0.0 {
      0x80000001 // ilogb(0) = 0x80000001
    } else if hx == 0 {
      let mut ix : Int = -1043
      while lx > 0 {
        lx = lx << 1
        ix -= 1
      }
      ix
    } else {
      let mut ix : Int = -1022
      hx = hx << 11
      while hx > 0 {
        hx = hx << 1
        ix -= 1
      }
      ix
    }
  } else if hx < 0x7ff00000 {
    (hx >> 20) - 1023
  } else {
    0x7fffffff
  }
}
