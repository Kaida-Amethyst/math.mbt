///| Computes the natural logarithm of the standard normal cumulative distribution function.
pub fn log_ndtr(x : Double) -> Double {
  // let sqrt1_2 = 0.707106781186547524400844362104849039; // 1/sqrt(2)
  let t = x * SQRT1_OVER_2
  if x < -1.0 {
    log(erfcx(-t) / 2.0) - t * t
  } else {
    log1p(-erfc(t) / 2.0)
  }
}
