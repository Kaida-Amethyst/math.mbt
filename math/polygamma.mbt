///| Computes the polygamma function of order n at x.
pub fn polygamma(x : Double, n : Int) -> Double {
  let c = if n % 2 == 1 { 1.0 } else { -1.0 }
  let e = exp(lgamma(n.to_double() + 1.0))
  let z = zeta((n + 1).to_double(), x)
  c * e * z
}
