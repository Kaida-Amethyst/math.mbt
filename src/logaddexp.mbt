///| logaddexp(x1, x2) = log(exp(x1) + exp(x2))
pub fn logaddexp(x1: Double, x2: Double) -> Double {
  if not(isfinite(x1)) {
    return x1;
  } else if not(isfinite(x2)) {
    return x2;
  }
  let temp: Double = x1 - x2;
  if temp > 0 {
    x1 + log1p(exp(-temp));
  } else {
    x2 + log1p(exp(temp));
  }
}
