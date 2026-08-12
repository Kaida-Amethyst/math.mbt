///|
/// Return the base 10 logarithm of `x`
///
/// # Examples
///
/// ```moonbit nocheck
/// assert_eq(log10(1), 0)
/// assert_eq(log10(2), 0.3010299956639812)
/// assert_eq(log10(3), 0.47712125471966244)
/// assert_eq(log10(4), 0.6020599913279624)
/// ```
///
/// # Special cases
///
/// 1. log10(x) = NaN for all x < 0
/// 2. log10(inf) = inf
/// 3. log10(0) = -inf
/// 4. log10(NaN) = NaN
/// 5. log10(10**n) = n for n = 0, 1, ..., 22
///
/// # Accuracy
///
/// 0 ulp (unit in the last place)
///
pub fn log10(x : Double) -> Double {
  if x == 0 {
    return @double.neg_infinity
  }
  if x < 0 || isnan(x) {
    return @double.not_a_number
  }
  if isinf(x) {
    return @double.infinity
  }
  let mut x = x
  let two54 = 1.80143985094819840000e+16 // 0x43500000, 0x00000000
  let ivln10 = 4.34294481903251816668e-01 // 0x3FDBCB7B, 0x1526E50E
  let log10_2hi = 3.01029995663611771306e-01 // 0x3FD34413, 0x509F6000
  let log10_2lo = 3.69423907715893078616e-13 // 0x3D59FEF3, 0x11F12B36
  let mut hx : Int = __hi(x).reinterpret_as_int()
  let lx : Int = __low(x).reinterpret_as_int()
  let mut k = 0
  if hx < 0x00100000 {
    k -= 54
    x *= two54 // subnormal number, scale up x
    hx = __hi(x).reinterpret_as_int() // high word of x
  }
  k += (hx >> 20) - 1023
  let i = (k.reinterpret_as_uint() & 0x80000000) >> 31
  let i = i.reinterpret_as_int()
  hx = (hx & 0x000fffff) | ((0x3ff - i) << 20)
  let y = (k + i).to_double()
  x = __combineW(hx.reinterpret_as_uint(), lx.reinterpret_as_uint())
  let z = y * log10_2lo + ivln10 * log(x)
  z + y * log10_2hi
}
