///| Return the base 10 logarithm of `x`
/// # Introduction
///
/// Return the base 10 logarithm of `x`
///
/// # Special cases
///
/// `log10(x)` is `NaN` with signal if `x < 0`
/// `log10(+INF)` is `+INF` with no signal
/// `log10(0)` is `-INF` with signal
/// `log10(NaN)` is that `NaN` with no signal
/// `log10(10**N) = N` for `N=0,1,...,22`
///
/// # Accuracy
///
/// 1 ulp (unit in the last place)
///
/// # Notes
///
/// 1. To guarantee `log10(10**n)=n`, where `10**n` is normal, the rounding mode must set to Round-to-Nearest.
/// 2. `[1/log(10)]` rounded to 53 bits has error  .198   ulps
/// 3. `log10` is monotonic at all binary break points
//  * Method :
//  *	Let log10_2hi = leading 40 bits of log10(2) and
//  *	    log10_2lo = log10(2) - log10_2hi,
//  *	    ivln10   = 1/log(10) rounded.
//  *	Then
//  *		n = ilogb(x), 
//  *		if(n<0)  n = n+1;
//  *		x = scalbn(x,-n);
//  *		log10(x) := n*log10_2hi + (n*log10_2lo + ivln10*log(x))
pub fn log10(x: Double) -> Double {
  let mut x = x
  let two54 = 1.80143985094819840000e+16 // 0x43500000, 0x00000000
  let ivln10 = 4.34294481903251816668e-01 // 0x3FDBCB7B, 0x1526E50E
  let log10_2hi = 3.01029995663611771306e-01 // 0x3FD34413, 0x509F6000
  let log10_2lo = 3.69423907715893078616e-13 // 0x3D59FEF3, 0x11F12B36
  let zero = 0.0

  let mut hx : Int = __hi(x).reinterpret_as_int()
  let lx : Int = __low(x).reinterpret_as_int()
  let mut k = 0
  if hx < 0x00100000 {
    // x < 2**-1022
    if ((hx & 0x7fffffff) | lx) == 0 {
      return -two54 / zero // log(+-0)=-inf
    }
    if hx < 0 {
      return (x - x) / zero // log(-#) = NaN
    }
    k -= 54
    x *= two54 // subnormal number, scale up x
    hx = __hi(x).reinterpret_as_int() // high word of x
  }
  if hx >= 0x7ff00000 {
    return x + x
  }
  k += (hx >> 20) - 1023
  let i = (k & 0x80000000) >> 31
  hx = (hx & 0x000fffff) | ((0x3ff - i) << 20)
  let y = (k+i).to_double()
  x = __combineW(hx.reinterpret_as_uint(), lx.reinterpret_as_uint())
  let z = y * log10_2lo + ivln10 * log(x)
  z + y * log10_2hi
}
