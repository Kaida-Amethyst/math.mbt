

pub fn zeta(x: Double, y: Double) -> Double {
  let machep = 1.11022302462515654042e-16
  let ns = [12.0, -720.0, 30240.0, -1209600.0, 47900160.0,
  -1.8924375803183791606e9, 7.47242496e10,
  -2.950130727918164224e12, 1.1646782814350067249e14,
  -4.5979787224074726105e15, 1.8152105401943546773e17,
  -7.1661652561756670113e18]

  let mut i = 0
  let mut a = 0.0
  let mut b = 0.0
  let mut k = 0.0
  let mut s = 0.0
  let mut t = 0.0
  let mut w = 0.0
  let mut e = 0.0
  let mut f = 0.0

  if x == 1.0 {
    return double_pos_inf
  }

  if x < 1.0 {
    return double_neg_inf
  }

  if y <= 0.0 {
    if y == floor(y) {
      return double_pos_inf
    }
    if x != floor(x) {
      return double_nan
    }
  }
  s = pow(y, -x)
  a = y
  b = 0.0
  while i < 9 || a<= 9.0 {
    i += 1
    a += 1.0
    b = pow(a, -x)
    s += b
    if -machep * s < b && b < machep * s {
      return s
    }
  }
  w = a
  e = b * w / (x - 1.0)
  s += e
  f = 0.5 * b
  s = s - f
  a = 1.0
  k = 0.0
  for i = 0; i < 12 ; i = i + 1 {
    a *= x +k
    b /= w
    t = a * b / ns[i]
    s += t
    t = fabs(t / s)
    if t < machep {
      return s
    }
    k += 1.0
    a *= x + k
    b /= w
    k += 1.0
  }
  s
}
