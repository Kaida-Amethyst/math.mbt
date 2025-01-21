///| Compute the value of a polynomial at a point.
///
/// Given coef = [a_n, a_{n-1}, ..., a_1, a_0], compute the value of the polynomial:
/// p(x) = a_n * x^n + a_{n-1} * x^{n-1} + ... + a_1 * x + a_0
pub fn polevl(x : Double, coef : Array[Double]) -> Double {
  let mut res : Double = 0
  for i = 0; i < coef.length(); i = i + 1 {
    res = res * x + coef[i]
  }
  res
}

//                                          N
// Evaluate polynomial when coefficient of x  is 1.0.
// Otherwise same as polevl.
//
pub fn p1eval(x: Double, coef: Array[Double]) -> Double {
  let mut ans : Double = x + coef[0]
  let n = coef.length()
  for i in 1..<n {
    ans = ans * x + coef[i]
  }
  ans
}

test "polevl" {
  assert_eq!(polevl(2.0, [1.0, 2.0, 3.0]), 11.0) // 1 * 2^2 + 2 * 2 + 3 = 11
  assert_eq!(p1eval(2.0, [1.0, 2.0, 3.0]), 19.0)
}
