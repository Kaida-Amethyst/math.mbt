///| Return the base 10 logarithm of `x`
///
/// # Examples
///
/// ```moonbit
/// assert_eq!(log10(1), 0)
/// assert_eq!(log10(2), 0.3010299956639812)
/// assert_eq!(log10(3), 0.47712125471966244)
/// assert_eq!(log10(4), 0.6020599913279624)
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
    return double_neg_inf
  }
  if x < 0 || isnan(x) {
    return double_nan
  }
  if isinf(x) {
    return double_pos_inf
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

///|
test "log10" {
  fn assert_log10_ulp!(input, expect) {
    assert_ulp!(expect, log10(input), LOG10_MAX_ULP)
  }

  assert_log10_ulp!(-0.8, double_nan)
  assert_log10_ulp!(-3.141592653589793, double_nan)
  assert_log10_ulp!(-1.5707963267948966, double_nan)
  assert_log10_ulp!(-0.7853981633974483, double_nan)
  assert_log10_ulp!(0, double_neg_inf)
  assert_log10_ulp!(0.01, -2)
  assert_log10_ulp!(0.1, -1)
  assert_log10_ulp!(0.2, -0.6989700043360187)
  assert_log10_ulp!(0.3, -0.5228787452803376)
  assert_log10_ulp!(0.4, -0.3979400086720376)
  assert_log10_ulp!(0.5, -0.3010299956639812)
  assert_log10_ulp!(0.6, -0.22184874961635637)
  assert_log10_ulp!(0.7, -0.1549019599857432)
  assert_log10_ulp!(0.8, -0.09691001300805639)
  assert_log10_ulp!(0.9, -0.045757490560675115)
  assert_log10_ulp!(1, 0)
  assert_log10_ulp!(3.141592653589793, 0.4971498726941338)
  assert_log10_ulp!(1.5707963267948966, 0.19611987703015263)
  assert_log10_ulp!(0.7853981633974483, -0.10491011863382856)
  assert_log10_ulp!(-1, double_nan)
  assert_log10_ulp!(1, 0)
  assert_log10_ulp!(2, 0.3010299956639812)
  assert_log10_ulp!(3, 0.47712125471966244)
  assert_log10_ulp!(4, 0.6020599913279624)
  assert_log10_ulp!(5, 0.6989700043360189)
  assert_log10_ulp!(6, 0.7781512503836436)
  assert_log10_ulp!(7, 0.8450980400142568)
  assert_log10_ulp!(8, 0.9030899869919435)
  assert_log10_ulp!(9, 0.9542425094393249)
  assert_log10_ulp!(10, 1)
  assert_log10_ulp!(11, 1.041392685158225)
  assert_log10_ulp!(12, 1.0791812460476249)
  assert_log10_ulp!(13, 1.1139433523068367)
  assert_log10_ulp!(14, 1.146128035678238)
  assert_log10_ulp!(15, 1.1760912590556813)
  assert_log10_ulp!(16, 1.2041199826559248)
  assert_log10_ulp!(17, 1.2304489213782739)
  assert_log10_ulp!(18, 1.255272505103306)
  assert_log10_ulp!(19, 1.2787536009528289)
  assert_log10_ulp!(20, 1.3010299956639813)
  assert_log10_ulp!(21, 1.3222192947339193)
  assert_log10_ulp!(22, 1.3424226808222062)
  assert_log10_ulp!(23, 1.3617278360175928)
  assert_log10_ulp!(24, 1.380211241711606)
  assert_log10_ulp!(25, 1.3979400086720377)
  assert_log10_ulp!(100, 2)
  assert_log10_ulp!(1000, 3)
  assert_log10_ulp!(10000, 4)
  assert_log10_ulp!(100000, 5)
  assert_log10_ulp!(1000000, 6)
  assert_log10_ulp!(2.5, 0.3979400086720376)
  assert_log10_ulp!(3.4, 0.5314789170422551)
  assert_log10_ulp!(5.3, 0.724275869600789)
  assert_log10_ulp!(6.2, 0.7923916894982539)
  assert_log10_ulp!(7.1, 0.8512583487190752)
  assert_log10_ulp!(8.9, 0.9493900066449128)
  assert_log10_ulp!(9.8, 0.9912260756924949)
  assert_log10_ulp!(10.7, 1.0293837776852097)
  assert_log10_ulp!(101.6, 2.0068937079479006)
  assert_log10_ulp!(1.542, 0.1880843737149382)
  assert_log10_ulp!(2.846, 0.45423489574826553)
  assert_log10_ulp!(7.881, 0.8965813275057327)
  assert_log10_ulp!(3.772, 0.5765716840652907)
  assert_log10_ulp!(242.58711268945123, 2.3848677254814152)
  assert_log10_ulp!(21456.774415889613, 4.331564435306097)
  assert_log10_ulp!(1123.5582229412541, 3.0505955825379125)
  assert_log10_ulp!(-1.542, double_nan)
  assert_log10_ulp!(0, double_neg_inf)
  assert_log10_ulp!(-0, double_neg_inf)
  assert_log10_ulp!(double_nan, double_nan)
  assert_log10_ulp!(double_pos_inf, double_pos_inf)
  assert_log10_ulp!(double_neg_inf, double_nan)
}
