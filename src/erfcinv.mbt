///| Calculate the inverse complementary error function of the input argument.
///
/// # Special Cases
///
/// 1. erfcinv(+-0) = +Inf
/// 2. erfcinv(2) = -inf
/// 3. erfcinv(x) returns NaN for `x` outside [0, 2]
/// 4. erfcinv(NaN) = NaN
pub fn erfcinv(a: Double) -> Double {
  let mut t = 2.0 - a;
  let mut p = 0.0
  if a >= 2.1875e-3 && a <= 1.998125 {
    t = t * a
    t = - log2(t)
    p = -2.00998329e-10
    p = fma(p, t, 7.63788321e-09)
    p = fma(p, t, -9.44120231e-08)
    p = fma(p, t, 1.27279494e-08)
    p = fma(p, t, 8.98369126e-06)
    p = fma(p, t, -3.40910883e-05)
    p = fma(p, t, -7.70850747e-04)
    p = fma(p, t, 5.54407062e-03)
    p = fma(p, t, 1.60820886e-01)
    t = fma(p, t, 8.86226892e-01)
    t = fma(t, -a, t)
  } else {
    t = if a > 1 { t } else { a }
    t = log2(t)
    t = rsqrt(-t)
    p = 1.16093750e+2
    p = fma(p, t, -2.26577423e+2)
    p = fma(p, t, 1.96353668e+2)
    p = fma(p, t, -1.00602257e+2)
    p = fma(p, t, 3.46447067e+1)
    p = fma(p, t, -9.10134983e+0)
    p = fma(p, t, 2.65257812e+0)
    p = fma(p, t, 4.29913402e-2)
    p = fma(p, t, -4.46814462e-4)
    p = fma(1.201122409, t, p * t)
    if a > 1 { p = -p }
    t = 1.0 / p
  }
  return t
}
