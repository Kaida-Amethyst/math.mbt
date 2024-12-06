///| sqrt1pm1(x) compute sqrt(1 + x) - 1 with higher accuracy than the naive formula
pub fn sqrt1pm1(x: Double) -> Double {
  if (fabs(x) > 0.75)  {
    (1.0 + x).sqrt() - 1.0
  }else {
    expm1(log1p(x) / 2)
  }
}
