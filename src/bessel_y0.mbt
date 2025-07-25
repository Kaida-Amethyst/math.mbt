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

///| Compute Bessel function of the second kind of order zero
///
/// # Examples
///
/// ```moonbit
/// let inf = 1.0/0.0
/// assert_eq(y0(0), -inf)
/// assert_eq(y0(1), 0.08825696421567697)
/// assert_eq(y0(2), 0.5103756726497451)
/// assert_eq(y0(1.542), 0.3991886731083115)
/// ```
///
/// # Special Cases
///
/// 1. y0(nan) is nan
/// 2. y0(0) is 0
/// 3. y0(inf) is 0
///
/// # Accuracy
///
/// 2 ulp
pub fn y0(x : Double) -> Double {
  if isnan(x) || x < 0.0 {
    return @double.not_a_number
  }
  if x == 0 {
    return @double.neg_infinity
  }
  if isinf(x) {
    return 0.0
  }
  let hx = __hi(x).reinterpret_as_int()
  let ix = hx & 0x7fffffff
  let invsqrtpi = 5.64189583547756279280e-01
  let tpi = 6.36619772367581382433e-01
  let u00 = -7.38042951086872317523e-02 // 0xBFB2E4D6, 0x99CBD01F
  let u01 = 1.76666452509181115538e-01 // 0x3FC69D01, 0x9DE9E3FC
  let u02 = -1.38185671945596898896e-02 // 0xBF8C4CE8, 0xB16CFA97
  let u03 = 3.47453432093683650238e-04 // 0x3F36C54D, 0x20B29B6B
  let u04 = -3.81407053724364161125e-06 // 0xBECFFEA7, 0x73D25CAD
  let u05 = 1.95590137035022920206e-08 // 0x3E550057, 0x3B4EABD4
  let u06 = -3.98205194132103398453e-11 // 0xBDC5E43D, 0x693FB3C8
  let v01 = 1.27304834834123699328e-02 // 0x3F8A1270, 0x91C9C71A
  let v02 = 7.60068627350353253702e-05 // 0x3F13ECBB, 0xF578C6C1
  let v03 = 2.59150851840457805467e-07 // 0x3E91642D, 0x7FF202FD
  let v04 = 4.41110311332675467403e-10 // 0x3DFE5018, 0x3BD6D9EF
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
  if ix <= 0x3e400000 {
    return u00 + tpi * log(x)
  }
  let z = x * x
  let u = u00 +
    z * (u01 + z * (u02 + z * (u03 + z * (u04 + z * (u05 + z * u06)))))
  let v = 1.0 + z * (v01 + z * (v02 + z * (v03 + z * v04)))
  u / v + tpi * (j0(x) * ln(x))
}

///|
test "y0" {
  fn assert_y0_ulp(input, expect) raise {
    assert_ulp(expect, y0(input), Y0_MAX_ULP)
  }

  assert_y0_ulp(-0.8, @double.not_a_number)
  assert_y0_ulp(-0.7, @double.not_a_number)
  assert_y0_ulp(-0.6, @double.not_a_number)
  assert_y0_ulp(-0.5, @double.not_a_number)
  assert_y0_ulp(-0.4, @double.not_a_number)
  assert_y0_ulp(-0.3, @double.not_a_number)
  assert_y0_ulp(-0.2, @double.not_a_number)
  assert_y0_ulp(-0.1, @double.not_a_number)
  assert_y0_ulp(-0, @double.neg_infinity)
  assert_y0_ulp(-3.141592653589793, @double.not_a_number)
  assert_y0_ulp(-1.5707963267948966, @double.not_a_number)
  assert_y0_ulp(-0.7853981633974483, @double.not_a_number)
  assert_y0_ulp(0, @double.neg_infinity)
  assert_y0_ulp(0.1, -1.5342386513503667)
  assert_y0_ulp(0.2, -1.0811053223721152)
  assert_y0_ulp(0.3, -0.8072735778045196)
  assert_y0_ulp(0.4, -0.6060245684270096)
  assert_y0_ulp(0.5, -0.44451873350670656)
  assert_y0_ulp(0.6, -0.3085098701155904)
  assert_y0_ulp(0.7, -0.19066492933739512)
  assert_y0_ulp(0.8, -0.08680227965660672)
  assert_y0_ulp(0.9, 0.005628306635205575)
  assert_y0_ulp(1, 0.08825696421567697)
  assert_y0_ulp(3.141592653589793, 0.32836630851631277)
  assert_y0_ulp(1.5707963267948966, 0.4100036450465759)
  assert_y0_ulp(0.7853981633974483, -0.1012071123915492)
  assert_y0_ulp(-1, @double.not_a_number)
  assert_y0_ulp(-2, @double.not_a_number)
  assert_y0_ulp(1, 0.08825696421567697)
  assert_y0_ulp(2, 0.5103756726497451)
  assert_y0_ulp(3, 0.3768500100127904)
  assert_y0_ulp(4, -0.016940739325064996)
  assert_y0_ulp(5, -0.30851762524903376)
  assert_y0_ulp(6, -0.28819468398157916)
  assert_y0_ulp(7, -0.02594974396720926)
  assert_y0_ulp(8, 0.2235214893875662)
  assert_y0_ulp(9, 0.24993669828502466)
  assert_y0_ulp(10, 0.055671167283599395)
  assert_y0_ulp(100, -0.07724431336508317)
  assert_y0_ulp(1000, 0.004715917977622814)
  assert_y0_ulp(10000, 0.0036478055589866053)
  assert_y0_ulp(2.5, 0.4980703596152318)
  assert_y0_ulp(3.4, 0.22961533720963104)
  assert_y0_ulp(5.3, -0.33743730109368286)
  assert_y0_ulp(6.2, -0.24830995051601423)
  assert_y0_ulp(7.1, 0.004181793191711063)
  assert_y0_ulp(8.9, 0.25915576172171056)
  assert_y0_ulp(9.8, 0.1045270839992337)
  assert_y0_ulp(10.7, -0.11218588966829603)
  assert_y0_ulp(101.6, 0.022058569700717928)
  assert_y0_ulp(1.542, 0.3991886731083115)
  assert_y0_ulp(2.846, 0.4234370194572033)
  assert_y0_ulp(7.881, 0.20302699116200357)
  assert_y0_ulp(3.772, 0.07611452144618826)
  assert_y0_ulp(-1.542, @double.not_a_number)
  assert_y0_ulp(-2.846, @double.not_a_number)
  assert_y0_ulp(@double.not_a_number, @double.not_a_number)
  assert_y0_ulp(@double.infinity, 0)
  assert_y0_ulp(@double.neg_infinity, @double.not_a_number)
}
