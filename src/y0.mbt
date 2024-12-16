///| Compute Bessel function of the second kind of order zero
/// # Special Cases
///
/// 1. y0(nan) is nan
/// 2. y0(0) is 0
/// 3. y0(inf) is 0
// Method -- y0(x):
// 1. For x<2.
//    Since 
// 	y0(x) = 2/pi*(j0(x)*(ln(x/2)+Euler) + x^2/4 - ...)
//    therefore y0(x)-2/pi*j0(x)*ln(x) is an even function.
//    We use the following function to approximate y0,
// 	y0(x) = U(z)/V(z) + (2/pi)*(j0(x)*ln(x)), z= x^2
//    where 
// 	U(z) = u00 + u01*z + ... + u06*z^6
// 	V(z) = 1  + v01*z + ... + v04*z^4
//    with absolute approximation error bounded by 2**-72.
//    Note: For tiny x, U/V = u0 and j0(x)~1, hence
// 	y0(tiny) = u0 + (2/pi)*ln(tiny), (choose tiny<2**-27)
// 2. For x>=2.
// 		y0(x) = sqrt(2/(pi*x))*(p0(x)*cos(x0)+q0(x)*sin(x0))
// 	   where x0 = x-pi/4. It is better to compute sin(x0),cos(x0)
//    by the method mentioned above.
// 3. Special cases: y0(0)=-inf, y0(x<0)=NaN, y0(inf)=0.
pub fn y0(x: Double) -> Double {

  if isnan(x) || x <= 0.0{
    return double_nan
  }

  if ispinf(x) {
    return 0.0
  }

  let hx = __hi(x).reinterpret_as_int()
  let ix = hx & 0x7fffffff
  let invsqrtpi =  5.64189583547756279280e-01
  let tpi = 6.36619772367581382433e-01

  let u00  = -7.38042951086872317523e-02 // 0xBFB2E4D6, 0x99CBD01F
  let u01  =  1.76666452509181115538e-01 // 0x3FC69D01, 0x9DE9E3FC
  let u02  = -1.38185671945596898896e-02 // 0xBF8C4CE8, 0xB16CFA97
  let u03  =  3.47453432093683650238e-04 // 0x3F36C54D, 0x20B29B6B
  let u04  = -3.81407053724364161125e-06 // 0xBECFFEA7, 0x73D25CAD
  let u05  =  1.95590137035022920206e-08 // 0x3E550057, 0x3B4EABD4
  let u06  = -3.98205194132103398453e-11 // 0xBDC5E43D, 0x693FB3C8
  let v01  =  1.27304834834123699328e-02 // 0x3F8A1270, 0x91C9C71A
  let v02  =  7.60068627350353253702e-05 // 0x3F13ECBB, 0xF578C6C1
  let v03  =  2.59150851840457805467e-07 // 0x3E91642D, 0x7FF202FD
  let v04  =  4.41110311332675467403e-10 // 0x3DFE5018, 0x3BD6D9EF

  if fabs(x) >= 2.0 {
    let s = sin(x)
    let c = cos(x)
    let mut ss = s - c
    let mut cc = s + c
    if ix < 0x7fe00000 {
      let z = -cos(x + x)
      if s * c < 0.0 {
        cc = z / ss
      } else {
        ss = z / cc
      }
    }
    let z = if ix > 0x48000000 {
      invsqrtpi * ss / sqrt(x)
    } else {
      let u = pzero(x)
      let v = qzero(x)
      invsqrtpi * (u * ss + v * cc) / sqrt(x)
    }
    return z
  }
  if ix < 0x3e400000 {
    return u00 + tpi * log(x)
  }
  let z = x * x
  let u = u00 + z * (u01 + z * (u02 + z * (u03 + z * (u04 + z * (u05 + z * u06)))))
  let v = 1.0 + z * (v01 + z * (v02 + z * (v03 + z * v04)))
  u / v + tpi * (j0(x) * log(x))
}
