///| `sinc` Compute sin(x) / x with high accuracy.
pub fn sinc(x : Double) -> Double {
  if x == 0.0 {
    return 1.0
  } else {
    let product = DOUBLE_PI * x
    return sin(product) / product
  }
}
