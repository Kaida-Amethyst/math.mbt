///| `atan2(y, x)` returns the angle whose tangent is `y/x`.
/// # Special Cases:
///
/// 1. `atan2((anything), NaN)` is NaN;
/// 2. `atan2(NAN, (anything))` is NaN;
/// 3. `atan2(+-0, +(anything but NaN))` is +-0;
/// 4. `atan2(+-0, -(anything but NaN))` is +-pi;
/// 5. `atan2(+-(anything but 0 and NaN), 0)` is +-pi/2;
/// 6. `atan2(+-(anything but INF and NaN), +INF)` is +-0;
/// 7. `atan2(+-(anything but INF and NaN), -INF)` is +-pi;
/// 8. `atan2(+-INF,+INF)` is +-pi/4;
/// 9. `atan2(+-INF,-INF)` is +-3pi/4;
/// 10. `atan2(+-INF, (anything but,0,NaN, and INF))` is +-pi/2;
pub fn atan2(y : Double, x : Double) -> Double {
  if isnan(x) || isnan(y) {
    double_nan
  } else if y == 0 {
    if x >= 0 {
      copysign(0, y)
    } else {
      copysign(PI, y)
    }
  } else if x == 0 {
    copysign(PI_OVER_2, y)
  } else if isinf(x) {
    if x.is_pos_inf() {
      if isinf(y) {
        copysign(PI_OVER_4, y)
      } else {
        copysign(0, y)
      }
    } else if isinf(y) {
      copysign(3.0 * PI_OVER_4, y)
    } else {
      copysign(PI, y)
    }
  } else if isinf(y) {
    copysign(PI_OVER_2, y)
  } else {
    let q = atan(y / x)
    if x < 0 {
      if q <= 0 {
        q + PI
      } else {
        q - PI
      }
    } else {
      q
    }
  }
}
