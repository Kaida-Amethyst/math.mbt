let tan_p = [
  -0x3325.B1A49E7E6F070EEA7F33, 0x1199EC.A5FC9DDCB62A659C2F5C, -0x111FEAD.3299175F331F9B486E14,
]

let tan_q = [
  1.0, 0x3571.4BDD66CAE3B4F57353EC, -0x1427BC.582ABC95B9AA3C9963BF, 0x17D98FC.2EAD8EF5BE3D475ECC36,
  -0x335FC07.97CB461BD8709633FE8F,
]

///| Compute the tangent of double-precision floating-point number `x`.
pub fn tan(x : Double) -> Double {
  if Double::is_inf(x) || Double::is_nan(x) {
    double_nan
  } else {
    let x_ = x.abs()
    let mut j = (x_ * pi4).to_int64()
    if (j & 1L) == 1L {
      j += 1L
    }
    let y = j.to_double()
    let z = x_ - y * pi4a - y * pi4b - y * pi4c
    let mut zz = z * z
    zz = if zz > 1.0e-14 {
      z +
      z *
      (
        zz *
        ((tan_p[0] * zz + tan_p[1]) * zz + tan_p[2]) /
        ((((zz + tan_q[1]) * zz + tan_q[2]) * zz + tan_q[3]) * zz + tan_q[4])
      )
    } else {
      z
    }
    if (j & 2L) == 2L {
      zz = -1.0 / zz
    }
    if x.signum() < 0.0 {
      -zz
    } else {
      zz
    }
  }
}

test "tan" {
  fn assert_tan_ulp!(input, expect) {
    assert_ulp!(expect, tan(input), TAN_MAX_ULP);
  }
  assert_tan_ulp!(-0.8, -1.0296385570503641)
  assert_tan_ulp!(-0.7, -0.8422883804630794)
  assert_tan_ulp!(-0.6, -0.6841368083416923)
  assert_tan_ulp!(-0.5, -0.5463024898437905)
  assert_tan_ulp!(-0.4, -0.4227932187381618)
  assert_tan_ulp!(-0.3, -0.30933624960962325)
  assert_tan_ulp!(-0.2, -0.2027100355086725)
  assert_tan_ulp!(-0.1, -0.10033467208545055)
  assert_tan_ulp!(-0, -0)
  // assert_tan_ulp!(-3.141592653589793, 0.00000000000000012246467991473532)
  // assert_tan_ulp!(-1.5707963267948966, -16331239353195370)
  assert_tan_ulp!(-0.7853981633974483, -0.9999999999999999)
  assert_tan_ulp!(0, 0)
  assert_tan_ulp!(0.1, 0.10033467208545055)
  assert_tan_ulp!(0.2, 0.2027100355086725)
  assert_tan_ulp!(0.3, 0.30933624960962325)
  assert_tan_ulp!(0.4, 0.4227932187381618)
  assert_tan_ulp!(0.5, 0.5463024898437905)
  assert_tan_ulp!(0.6, 0.6841368083416923)
  assert_tan_ulp!(0.7, 0.8422883804630794)
  assert_tan_ulp!(0.8, 1.0296385570503641)
  assert_tan_ulp!(0.9, 1.2601582175503392)
  assert_tan_ulp!(1, 1.5574077246549023)
  // assert_tan_ulp!(3.141592653589793, -0.00000000000000012246467991473532)
  // assert_tan_ulp!(1.5707963267948966, 16331239353195370)
  assert_tan_ulp!(0.7853981633974483, 0.9999999999999999)
  assert_tan_ulp!(-1, -1.5574077246549023)
  assert_tan_ulp!(-2, 2.185039863261519)
  assert_tan_ulp!(-3, 0.1425465430742778)
  assert_tan_ulp!(-4, -1.1578212823495775)
  assert_tan_ulp!(-5, 3.380515006246586)
  assert_tan_ulp!(-6, 0.29100619138474915)
  assert_tan_ulp!(-7, -0.8714479827243188)
  assert_tan_ulp!(-8, 6.799711455220379)
  assert_tan_ulp!(-9, 0.45231565944180985)
  assert_tan_ulp!(1, 1.5574077246549023)
  assert_tan_ulp!(2, -2.185039863261519)
  assert_tan_ulp!(3, -0.1425465430742778)
  assert_tan_ulp!(4, 1.1578212823495775)
  assert_tan_ulp!(5, -3.380515006246586)
  assert_tan_ulp!(6, -0.29100619138474915)
  assert_tan_ulp!(7, 0.8714479827243188)
  assert_tan_ulp!(8, -6.799711455220379)
  assert_tan_ulp!(9, -0.45231565944180985)
  assert_tan_ulp!(10, 0.6483608274590866)
  assert_tan_ulp!(100, -0.5872139151569291)
  assert_tan_ulp!(1000, 1.4703241557027185)
  assert_tan_ulp!(10000, 0.3209711346238147)
  assert_tan_ulp!(2.5, -0.7470222972386603)
  assert_tan_ulp!(3.4, 0.26431690086742515)
  assert_tan_ulp!(5.3, -1.50127339580693)
  assert_tan_ulp!(6.2, -0.08337771486592861)
  assert_tan_ulp!(7.1, 1.0648931268833821)
  assert_tan_ulp!(8.9, -0.578923587933547)
  assert_tan_ulp!(9.8, 0.3938830407517425)
  assert_tan_ulp!(10.7, 3.2841408053775507)
  assert_tan_ulp!(101.6, 1.8228497299403925)
  assert_tan_ulp!(1.542, 34.71705201708467)
  assert_tan_ulp!(2.846, -0.3045137125920165)
  assert_tan_ulp!(7.881, -37.00285415158369)
  assert_tan_ulp!(3.772, 0.7297388097669394)
  assert_tan_ulp!(-1.542, -34.71705201708467)
  assert_tan_ulp!(-2.846, 0.3045137125920165)
  assert_tan_ulp!(-7.881, 37.00285415158369)
  assert_tan_ulp!(-3.772, -0.7297388097669394)
  assert_tan_ulp!(-1, -1.5574077246549023)
  assert_tan_ulp!(0, 0)
  assert_tan_ulp!(-0, -0)
  assert_tan_ulp!(double_nan, double_nan)
  assert_tan_ulp!(double_pos_inf, double_nan)
  assert_tan_ulp!(double_neg_inf, double_nan)
}
