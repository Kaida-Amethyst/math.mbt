///| Compute arctangent of `x`
///
/// # Examples
///
/// ```moonbit
/// assert_eq!(atan(0), 0)
/// assert_eq!(atan(1), 0.7853981633974483)
/// assert_eq!(atan(2), 1.1071487177940904)
/// assert_eq!(atan(-1),-0.7853981633974483)
/// assert_eq!(atan(-2),-1.1071487177940904)
/// let (pinf, ninf) = (1.0/0.0, -1.0/0.0)
/// assert_eq!(atan(pinf), 1.5707963267948966)
/// assert_eq!(atan(ninf), -1.5707963267948966)
/// ```
///
/// # Accuracy
///
/// 1 ulp (unit in the last place).
///
/// # Special Cases
/// 
/// 1. atan(NaN) = NaN
/// 2. atan(+Inf) = +π/2
/// 3. atan(-Inf) = -π/2
pub fn atan(x: Double) -> Double {
  if x.is_nan() || x == 0.0 {
    return x;
  }

  let atan_hi = [
    4.63647609000806093515e-01,
    7.85398163397448278999e-01,
    9.82793723247329054082e-01,
    1.57079632679489655800e+00,
  ];

  let atan_lo = [
    2.26987774529616870924e-17,
    3.06161699786838301793e-17,
    1.39033110312309984516e-17,
    6.12323399573676603587e-17,
  ];

  let a_t = [
    3.33333333333329318027e-01,
    -1.99999999998764832476e-01,
    1.42857142725034663711e-01,
    -1.11111104054623557880e-01,
    9.09088713343650656196e-02,
    -7.69187620504482999495e-02,
    6.66107313738753120669e-02,
    -5.83357013379057348645e-02,
    4.97687799461593236017e-02,
    -3.65315727442169155270e-02,
    1.62858201153657823623e-02,
  ];

  let one = 1.0;
  let huge = 1.0e300;

  let ix = __hi(x).reinterpret_as_int() & 0x7fffffff;
  let mut id = 0
  let mut z = 0.0;
  let mut w = 0.0;
  let mut x = x
  let x_is_neg = x < 0.0;

  if ix >= 0x44100000 {
    if x > 0 {
      return atan_hi[3] + atan_lo[3];
    } else {
      return -atan_hi[3] - atan_lo[3];
    }
  }

  if ix < 0x3fdc0000 {
    if ix < 0x3e200000 {
      if huge + x > one {
        return x;
      }
    }
    id = -1;
  } else {
    x = x.abs();
    if ix < 0x3ff30000 {
      if ix < 0x3fe60000 {
        id = 0;
        x = (2.0 * x - one) / (2.0 + x);
      } else {
        id = 1;
        x = (x - one) / (x + one);
      }
    } else {
      if ix < 0x40038000 {
        id = 2;
        x = (x - 1.5) / (one + 1.5 * x);
      } else {
        id = 3;
        x = -1.0 / x;
      }
    }
  }

  z = x * x;
  w = z * z;

  let s1 = z * (a_t[0] + w * (a_t[2] + w * (a_t[4] + w * (a_t[6] + w * (a_t[8] + w * a_t[10])))));
  let s2 = w * (a_t[1] + w * (a_t[3] + w * (a_t[5] + w * (a_t[7] + w * a_t[9]))));


  if id < 0 {
    x - x * (s1 + s2)
  } else {
    z = atan_hi[id] - ((x * (s1 + s2) - atan_lo[id]) - x);
    if x_is_neg {
      -z
    } else {
      z
    }
  }
}

test "atan" {
  fn assert_atan_ulp!(input, expect) {
    assert_ulp!(expect, atan(input), ATAN_MAX_ULP);
  }
  assert_atan_ulp!(0, 0);
  assert_atan_ulp!(1, 0.7853981633974483);
  assert_atan_ulp!(2, 1.1071487177940906);
  assert_atan_ulp!(3, 1.2490457723982544);
  assert_atan_ulp!(4, 1.3258176636680326);
  assert_atan_ulp!(5, 1.373400766945016);
  assert_atan_ulp!(6, 1.4056476493802699);
  assert_atan_ulp!(7, 1.4288992721907328);
  assert_atan_ulp!(8, 1.446441332248135);
  assert_atan_ulp!(9, 1.460139105621001);
  assert_atan_ulp!(10, 1.4711276743037345);
  assert_atan_ulp!(11, 1.4801364395941514);
  assert_atan_ulp!(12, 1.4876550949064553);
  assert_atan_ulp!(13, 1.4940244355251187);
  assert_atan_ulp!(14, 1.4994888620096063);
  assert_atan_ulp!(15, 1.5042281630190728);
  assert_atan_ulp!(-1, -0.7853981633974483);
  assert_atan_ulp!(-2, -1.1071487177940906);
  assert_atan_ulp!(-3, -1.2490457723982544);
  assert_atan_ulp!(-4, -1.3258176636680326);
  assert_atan_ulp!(-5, -1.373400766945016);
  assert_atan_ulp!(-6, -1.4056476493802699);
  assert_atan_ulp!(-7, -1.4288992721907328);
  assert_atan_ulp!(-8, -1.446441332248135);
  assert_atan_ulp!(-9, -1.460139105621001);
  assert_atan_ulp!(-10, -1.4711276743037345);
  assert_atan_ulp!(-11, -1.4801364395941514);
  assert_atan_ulp!(-12, -1.4876550949064553);
  assert_atan_ulp!(-13, -1.4940244355251187);
  assert_atan_ulp!(-14, -1.4994888620096063);
  assert_atan_ulp!(-15, -1.5042281630190728);
  assert_atan_ulp!(0.12, 0.11942892601833845);
  assert_atan_ulp!(0.23, 0.2260683879938839);
  assert_atan_ulp!(0.34, 0.3277385067805555);
  assert_atan_ulp!(0.45, 0.4228539261329407);
  assert_atan_ulp!(0.56, 0.5104883219167758);
  assert_atan_ulp!(0.67, 0.590306746935372);
  assert_atan_ulp!(0.78, 0.6624262938331512);
  assert_atan_ulp!(0.89, 0.7272626879966904);
  assert_atan_ulp!(0.9, 0.7328151017865067);
  assert_atan_ulp!(-0.87, -0.7159911144163001);
  assert_atan_ulp!(-0.76, -0.6498704494119476);
  assert_atan_ulp!(-0.65, -0.5763752205911837);
  assert_atan_ulp!(-0.54, -0.49513326346840414);
  assert_atan_ulp!(-0.43, -0.40609805831761564);
  assert_atan_ulp!(-0.32, -0.3097029445424562);
  assert_atan_ulp!(-0.21, -0.206992194219821);
  assert_atan_ulp!(-0.1, -0.09966865249116204);
  assert_atan_ulp!(0.12345, 0.12282855068741544);
  assert_atan_ulp!(0.23456, 0.2303949468807241);
  assert_atan_ulp!(0.34567, 0.33281216252994195);
  assert_atan_ulp!(0.45678, 0.42847785122558607);
  assert_atan_ulp!(0.56789, 0.5164745097842471);
  assert_atan_ulp!(0.6789, 0.5964240851188558);
  assert_atan_ulp!(0.78901, 0.6680037059425237);
  assert_atan_ulp!(0.89012, 0.7273296445553981);
  assert_atan_ulp!(0.90123, 0.7334942443279985);
  assert_atan_ulp!(-0.98765, -0.7791848758086322);
  assert_atan_ulp!(-0.87654, -0.7197015466378203);
  assert_atan_ulp!(-0.76543, -0.6533033928690293);
  assert_atan_ulp!(-0.65432, -0.5794061351524672);
  assert_atan_ulp!(-0.54321, -0.49761521700698697);
  assert_atan_ulp!(-0.4321, -0.4078690083022377);
  assert_atan_ulp!(-0.32109, -0.3106913832920783);
  assert_atan_ulp!(-0.21098, -0.20793061638727955);
  assert_atan_ulp!(-0.10987, -0.10943107915405893);
  assert_atan_ulp!(1.234, 0.8897624489591893);
  assert_atan_ulp!(2.345, 1.1677072684050145);
  assert_atan_ulp!(3.456, 1.2891368759113806);
  assert_atan_ulp!(4.567, 1.3552362032374148);
  assert_atan_ulp!(5.678, 1.3964657470487327);
  assert_atan_ulp!(6.789, 1.4245508462879888);
  assert_atan_ulp!(7.89, 1.4447258005561798);
  assert_atan_ulp!(8.901, 1.4589185265134277);
  assert_atan_ulp!(9.012, 1.4602852545944818);
  assert_atan_ulp!(10.123, 1.4723308430472324);
  assert_atan_ulp!(11.234, 1.4820148389775378);
  assert_atan_ulp!(12.345, 1.489968353486419);
  assert_atan_ulp!(13.456, 1.4966163991626389);
  assert_atan_ulp!(-1.234, -0.8897624489591893);
  assert_atan_ulp!(-2.345, -1.1677072684050145);
  assert_atan_ulp!(-3.456, -1.2891368759113806);
  assert_atan_ulp!(-4.567, -1.3552362032374148);
  assert_atan_ulp!(-5.678, -1.3964657470487327);
  assert_atan_ulp!(-6.789, -1.4245508462879888);
  assert_atan_ulp!(-7.89, -1.4447258005561798);
  assert_atan_ulp!(-8.901, -1.4589185265134277);
  assert_atan_ulp!(-9.012, -1.4602852545944818);
  assert_atan_ulp!(-10.123, -1.4723308430472324);
  assert_atan_ulp!(-11.234, -1.4820148389775378);
  assert_atan_ulp!(-12.345, -1.489968353486419);
  assert_atan_ulp!(-13.456, -1.4966163991626389);
  assert_atan_ulp!(3.1415926, 1.2626272507486684);
  assert_atan_ulp!(2.7182818, 1.2182829016248764);
  assert_atan_ulp!(1.6180339, 1.0172219433679828);
  assert_atan_ulp!(1.4142136, 0.9553166306668107);
  assert_atan_ulp!(1.7320508, 1.0471975493043784);
  assert_atan_ulp!(0.5772157, 0.5234978428250526);
  assert_atan_ulp!(0.3010299, 0.2924013888286663);
  assert_atan_ulp!(0.6931472, 0.6061119478640076);
  assert_atan_ulp!(0.4342945, 0.40971675933419394);
  assert_atan_ulp!(0.0000001, 0.00000009999999999999966);
  assert_atan_ulp!(1000000000, 1.5707963257948967);
  assert_atan_ulp!(31415926535897.1234, 1.5707963267948648);
  assert_atan_ulp!(-27182818284590.5678, -1.57079632679486);
  assert_atan_ulp!(@double.max_value, 1.5707963267948966);
  assert_atan_ulp!(@double.min_value, -1.5707963267948966);
  assert_atan_ulp!(@double.infinity, 1.5707963267948966);
  assert_atan_ulp!(@double.neg_infinity, -1.5707963267948966);
  assert_atan_ulp!(@double.not_a_number, @double.not_a_number);
}
