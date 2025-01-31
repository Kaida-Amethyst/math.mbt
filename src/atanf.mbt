pub fn atanf(x: Float) -> Float {
  let atanhi: Array[Float] = [
    4.6364760399e-01, 7.8539812565e-01,
    9.8279368877e-01, 1.5707962513e+00
  ];
  let atanlo : Array[Float] = [
    5.0121582440e-09, 3.7748947079e-08,
    3.4473217170e-08, 7.5497894159e-08
  ];
  let a_t : Array[Float] = [
    3.3333328366e-01, -1.9999158382e-01, 1.4253635705e-01, 
    -1.0648017377e-01, 6.1687607318e-02
  ];

  let ix = x.reinterpret_as_int();
  let sign = ix >> 31;
  let ix = ix & 0x7fffffff;
  let mut id = 0
  let mut x = x;
  let one: Float = 1.0;
  let two: Float = 2.0;

  if ix >= 0x4c800000 {
    if x.is_nan() {
      return x;
    }
    let z = atanhi[3] + 0x1.0p-120;
    let z = if sign != 0 {
      -z
    } else {
      z
    };
    return z
  }

  if ix < 0x3ee00000 {
    if ix < 0x39800000 {
      return x;
    }
    id = -1;
  } else {
    x = x.abs();
    if ix < 0x3f980000 {
      if ix < 0x3f300000 {
          id = 0;
          x = (two * x - one) / (two + x);
      } else {
          id = 1;
          x = (x - one) / (x + one);
      }
    } else {
      if ix < 0x401c0000 {
        id = 2;
        x = (x - 1.5) / (one + x * 1.5);
      } else {
        id = 3;
        x = -one / x;
      }
    }
  }

  let z = x * x;
  let w = z * z;

  let s1 = z * (a_t[0] + w * (a_t[2] + w * a_t[4]));
  let s2 = w * (a_t[1] + w * a_t[3]);

  if id < 0 {
    return x - x * (s1 + s2);
  }

  let z = atanhi[id] - ((x * (s1 + s2) - atanlo[id]) - x);
  if sign != 0 {
    -z
  } else {
    z
  }
}
