///| Compute the value of a polynomial at a point.
pub fn polevl(x: Double, coef: Array[Double]) -> Double {
  let mut res : Double = 0
  let len = coef.length()
  for i=0; i < len; i=i+1 {
    res = res * x + coef[i]
  }
  res
}
