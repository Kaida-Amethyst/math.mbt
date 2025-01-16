

// pub fn t_log10(x: Double) -> Double {
//   let ivln10 = 4.34294481903251816668e-01 // 0x3FDBCB7B, 0x1526E50E
//   let log10_2hi = 3.01029995663611771306e-01 // 0x3FD34413, 0x509F6000
//   let log10_2lo = 3.69423907715893078616e-13 // 0x3D59FEF3, 0x11F12B36
//   let (f, e) = @kmath.frexp(x)
//   let e = (e - 1).to_double()
//   let f = f * 2.0
//   let z = e * log10_2lo + ivln10 * @kmath.log(f)
//   z + e * log10_2hi
// }

pub fn t_log10(x: Double) -> Double {
  if x < 0 || x.is_nan() {
    return 0.0/0.0
  }
  if x.is_inf() {
    return x
  }
  let ivln10 = 4.34294481903251816668e-01
  let log10_2hi = 3.01029995663611771306e-01
  let log10_2lo = 3.69423907715893078616e-13
  let (f, e) = @kmath.frexp(x)
  let (f, e) = if e >= 1 {
    (f * 2.0, (e - 1).to_double())
  } else {
    (f, e.to_double())
  }
  let z = e * log10_2lo + ivln10 * f.ln()
  z + e * log10_2hi
}

fn main {
  // let x = 3.141592653589793
  let x = 15.0
  let ky = @kmath.log10(x)
  let iky = BigInt::from_uint64(ky.reinterpret_as_uint64()).to_hex(uppercase=false)
  // let y = @math.log10(x)
  let ty = t_log10(x)
  println("kmath log10(\{x}) = \{ky}(\{iky})")
  // println("cmath log10(\{x}) = \{y}")
  println("t_log10(\{x}) = \{ty}")
}
