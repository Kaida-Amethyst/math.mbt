///| gegenbauer computes the Gegenbauer polynomial of degree n with parameter lambda at x.
/// # Introduction
///
/// Gegenbauer polynomials are orthogonal polynomials on the interval [-1,1] with weight function (1-x^2)^lambda.
/// The formula for the Gegenbauer polynomial is
///
/// \[ C_n^{(\lambda)}(x) = \sum_{k=0}^n \binom{n}{k} \frac{\Gamma(n+2\lambda)}{\Gamma(n-k+1)\Gamma(2\lambda+k)} \left(\frac{x-1}{2}\right)^{n-k} \]
///
pub fn gegenbauer(n : UInt, lambda : Double, x : Double) -> Double {
  if lambda <= -1.0 / 2.0 {
    println("lambda > -1/2 is required.")
    return 0.0
  }
  if x < 0.0 {
    if (n & 1) != 0 {
      return -gegenbauer(n, lambda, -x)
    }
    return gegenbauer(n, lambda, -x)
  }
  if n == 0 {
    return 1.0
  }
  let mut y0 = 1.0
  let mut y1 = 2.0 * lambda * x
  let mut yk = y1
  let mut k = 2.0
  let n = n.to_uint64().to_double()
  let k_max = n * (1.0 + double_epsilon)
  let gamma = 2.0 * (lambda - 1.0)
  while k < k_max {
    yk = (2.0 + gamma / k) * x * y1 - (1.0 + gamma / k) * y0
    y0 = y1
    y1 = yk
    k += 1.0
  }
  yk
}

///| gegenbauer_derivative is the derivative of the Gegenbauer polynomial of degree n with parameter lambda at x.
pub fn gegenbauer_derivative(
  n : UInt,
  lambda : Double,
  x : Double,
  k : UInt,
) -> Double {
  if k > n {
    return 0.0
  }
  let kf = k.to_uint64().to_double()
  let gegen = gegenbauer(n - k, lambda + kf, x)
  let mut scale = 1.0
  let mut lambda = lambda
  // for j in 0..k {
  for j = 0U; j < k; j = j + 1 {
    scale *= 2.0 * lambda
    lambda += 1.0
  }
  scale * gegen
}

///|
pub fn gegenbauer_prime(n : UInt, lambda : Double, x : Double) -> Double {
  gegenbauer_derivative(n, lambda, x, 1)
}
