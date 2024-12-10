///| hermite(n, x) computes the nth Hermite polynomial at x.
/// # Introduction
///
/// hermite polynomials are a set of orthogonal polynomials that arise in the solution of the quantum harmonic oscillator.
/// the formula for the nth hermite polynomial is given by:
///
/// $$H_n(x) = (-1)^n * e^(x^2) * d^n/dx^n(e^(-x^2))$$
///
pub fn hermite(n: UInt, x: Double) -> Double {

  fn hermite_next(n : UInt, x: Double, hn: Double, hnm1: Double) -> Double {
    let n = n.to_uint64().to_double()
    return 2.0 * x * hn - 2.0 * n * hnm1;
  }

  let mut p0 : Double = 1.0
  let mut p1 : Double = 2.0 * x

  if n == 0 {
    return p0
  }

  let mut c : UInt = 1

  while c < n {
    let tmp = p0
    p0 = p1
    p1 = hermite_next(c, x, tmp, p1)
    c += 1
  }
  p1
}
