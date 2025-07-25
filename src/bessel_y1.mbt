// Method -- y1(x):
// 1. screen out x<=0 cases: y1(0)=-inf, y1(x<0)=NaN 
// 2. For x<2.
//    Since 
// 	y1(x) = 2/pi*(j1(x)*(ln(x/2)+Euler)-1/x-x/2+5/64*x^3-...)
//    therefore y1(x)-2/pi*j1(x)*ln(x)-1/x is an odd function.
//    We use the following function to approximate y1,
// 	y1(x) = x*U(z)/V(z) + (2/pi)*(j1(x)*ln(x)-1/x), z= x^2
//    where for x in [0,2] (abs err less than 2**-65.89)
// 	U(z) = U0[0] + U0[1]*z + ... + U0[4]*z^4
// 	V(z) = 1  + v0[0]*z + ... + v0[4]*z^5
//    Note: For tiny x, 1/x dominate y1 and hence
// 	y1(tiny) = -2/pi/tiny, (choose tiny<2**-54)
// 3. For x>=2.
// 		y1(x) = sqrt(2/(pi*x))*(p1(x)*sin(x1)+q1(x)*cos(x1))
// 	   where x1 = x-3*pi/4. It is better to compute sin(x1),cos(x1)
//    by method mentioned above.
//

///| Compute Bessel function of the second kind of order one.
///
/// # Examples
///
/// ```moonbit
/// let inf = 1.0/0.0
/// assert_eq(y1(0), -inf);
/// assert_eq(y1(1), -0.7812128213002887);
/// assert_eq(y1(2), -0.10703243154093756);
/// assert_eq(y1(1.542), -0.3848820110973209);
/// ```
///
/// # Special Cases
///
/// 1. `y1(x)` is NaN if `x` is NaN.
/// 2. `y1(x)` is 0 if `x` is ±∞.
/// 3. `y1(x)` is NaN if `x` is less than 0.
///
/// # Accuracy
///
/// 2 ulp
pub fn y1(x : Double) -> Double {
  if isnan(x) || x < 0.0 {
    return @double.not_a_number
  }
  if x == 0.0 {
    return @double.neg_infinity
  }
  if isinf(x) {
    return 0.0
  }
  let tpi = 6.36619772367581382433e-01 // 0x3FE45F30, 0x6DC9C883
  let invsqrtpi = 5.64189583547756279280e-01 // 0x3FE20DD7, 0x50429B6D
  let u0 = [
    -1.96057090646238940668e-01, // 0xBFC91866, 0x143CBC8A 
     5.04438716639811282616e-02, // 0x3FA9D3C7, 0x76292CD1 
     -1.91256895875763547298e-03, // 0xBF5F55E5, 0x4844F50F 
     2.35252600561610495928e-05, // 0x3EF8AB03, 0x8FA6B88E 
     -9.19099158039878874504e-08, // 0xBE78AC00, 0x569105B8 
  ]
  let v0 = [
    1.99167318236649903973e-02, // 0x3F94650D, 0x3F4DA9F0 
     2.02552581025135171496e-04, // 0x3F2A8C89, 0x6C257764 
     1.35608801097516229404e-06, // 0x3EB6C05A, 0x894E8CA6 
     6.22741452364621501295e-09, // 0x3E3ABF1D, 0x5BA69A86 
     1.66559246207992079114e-11, // 0x3DB25039, 0xDACA772A 
  ]
  let hx = __hi(x).reinterpret_as_int()
  let ix = 0x7fffffff & hx
  if fabs(x) >= 2.0 {
    let s = sin(x)
    let c = cos(x)
    let mut ss = -s - c
    let mut cc = s - c
    if ix < 0x7fe00000 {
      let z = cos(x + x)
      if s * c > 0.0 {
        cc = z / ss
      } else {
        ss = z / cc
      }
    }
    let z = if ix > 0x48000000 {
      invsqrtpi * ss / sqrt(x)
    } else {
      let u = pone(x)
      let v = qone(x)
      invsqrtpi * (u * ss + v * cc) / sqrt(x)
    }
    return z
  }
  if ix <= 0x3c900000 {
    return -tpi / x
  }
  let z = x * x
  let u = u0[0] + z * (u0[1] + z * (u0[2] + z * (u0[3] + z * u0[4])))
  let v = 1.0 +
    z * (v0[0] + z * (v0[1] + z * (v0[2] + z * (v0[3] + z * v0[4]))))
  x * (u / v) + tpi * (j1(x) * ln(x) - 1.0 / x)
}

///|
test "y1" {
  fn assert_y1_ulp(input, expect) raise {
    assert_ulp(expect, y1(input), Y1_MAX_ULP)
  }

  assert_y1_ulp(-0.8, @double.not_a_number)
  assert_y1_ulp(-0.7, @double.not_a_number)
  assert_y1_ulp(-0.1, @double.not_a_number)
  assert_y1_ulp(-0, @double.neg_infinity)
  assert_y1_ulp(-3.141592653589793, @double.not_a_number)
  assert_y1_ulp(-1.5707963267948966, @double.not_a_number)
  assert_y1_ulp(-0.7853981633974483, @double.not_a_number)
  assert_y1_ulp(0, @double.neg_infinity)
  assert_y1_ulp(0.1, -6.458951094702027)
  assert_y1_ulp(0.2, -3.323824988111847)
  assert_y1_ulp(0.3, -2.2931051383885293)
  assert_y1_ulp(0.4, -1.7808720442700516)
  assert_y1_ulp(0.5, -1.4714723926702433)
  assert_y1_ulp(0.6, -1.2603913471773878)
  assert_y1_ulp(0.7, -1.1032498719076336)
  assert_y1_ulp(0.8, -0.9781441766833591)
  assert_y1_ulp(0.9, -0.873126582456329)
  assert_y1_ulp(1, -0.7812128213002887)
  assert_y1_ulp(3.141592653589793, 0.35887291677671895)
  assert_y1_ulp(1.5707963267948966, -0.36628039556285696)
  assert_y1_ulp(0.7853981633974483, -0.9949447030788668)
  assert_y1_ulp(-1, @double.not_a_number)
  assert_y1_ulp(-2, @double.not_a_number)
  assert_y1_ulp(-8, @double.not_a_number)
  assert_y1_ulp(-9, @double.not_a_number)
  assert_y1_ulp(1, -0.7812128213002887)
  assert_y1_ulp(2, -0.10703243154093756)
  assert_y1_ulp(3, 0.3246744247917999)
  assert_y1_ulp(4, 0.3979257105571)
  assert_y1_ulp(5, 0.1478631433912268)
  assert_y1_ulp(6, -0.17501034430039827)
  assert_y1_ulp(7, -0.30266723702418485)
  assert_y1_ulp(8, -0.15806046173124752)
  assert_y1_ulp(9, 0.10431457519671589)
  assert_y1_ulp(10, 0.2490154242069538)
  assert_y1_ulp(100, -0.020372312002759792)
  assert_y1_ulp(1000, -0.02478433129235178)
  assert_y1_ulp(10000, 0.007096342752536495)
  assert_y1_ulp(2.5, 0.14591813796678577)
  assert_y1_ulp(3.4, 0.4010152921084735)
  assert_y1_ulp(5.3, 0.04454761908760843)
  assert_y1_ulp(6.2, -0.22228364062007436)
  assert_y1_ulp(7.1, -0.2994788746009546)
  assert_y1_ulp(8.9, 0.07986939739413693)
  assert_y1_ulp(9.8, 0.23789324208617227)
  assert_y1_ulp(10.7, 0.21144477627466574)
  assert_y1_ulp(101.6, -0.07591398429913061)
  assert_y1_ulp(1.542, -0.3848820110973209)
  assert_y1_ulp(2.846, 0.2788929981992953)
  assert_y1_ulp(7.881, -0.18605472090659053)
  assert_y1_ulp(3.772, 0.41521302902666374)
  assert_y1_ulp(-1.542, @double.not_a_number)
  assert_y1_ulp(-2.846, @double.not_a_number)
  assert_y1_ulp(-7.881, @double.not_a_number)
  assert_y1_ulp(-3.772, @double.not_a_number)
  assert_y1_ulp(-1, @double.not_a_number)
  assert_y1_ulp(0, @double.neg_infinity)
  assert_y1_ulp(-0, @double.neg_infinity)
  assert_y1_ulp(@double.not_a_number, @double.not_a_number)
  assert_y1_ulp(@double.infinity, 0)
  assert_y1_ulp(@double.neg_infinity, @double.not_a_number)
}
