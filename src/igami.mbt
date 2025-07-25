///|
fn interval_halving(
  a : Double,
  y0 : Double,
  x : Double,
  x0 : Double,
  x1 : Double,
  yl : Double,
  yh : Double,
  dithresh : Double,
) -> Double {
  let mut d = 0.0625
  let mut x0 = x0
  let mut yl = yl
  let mut yh = yh
  let mut x1 = x1
  let mut x = x

  // Handle the initial case where x0 is DOUBLE_MAX
  if x0 == DOUBLE_MAX {
    if x <= 0.0 {
      x = 1.0
    }
    while x0 == DOUBLE_MAX {
      x = (1.0 + d) * x
      let y = igamc(a, x)
      if y < y0 {
        x0 = x
        yl = y
        break
      }
      d += d
    }
  }
  d = 0.5
  let mut dir = 0
  for _ in 0..<400 {
    x = x1 + d * (x0 - x1)
    let y = igamc(a, x)
    let mut lgm = (x0 - x1) / (x1 + x0)
    if lgm.abs() < dithresh {
      break
    }
    lgm = (y - y0) / y0
    if lgm.abs() < dithresh {
      break
    }
    if x <= 0.0 {
      break
    }
    if y >= y0 {
      x1 = x
      yh = y
      if dir < 0 {
        dir = 0
        d = 0.5
      } else if dir > 1 {
        d = 0.5 * d + 0.5
      } else {
        d = (y0 - yl) / (yh - yl)
      }
      dir += 1
    } else {
      x0 = x
      yl = y
      if dir > 0 {
        dir = 0
        d = 0.5
      } else if dir < -1 {
        d *= 0.5
      } else {
        d = (y0 - yl) / (yh - yl)
      }
      dir -= 1
    }
  }
  x
}

///| Inverse of complemented incomplete gamma function
pub fn igami(a : Double, y0 : Double) -> Double {
  let mut x0 = DOUBLE_MAX
  let mut yl = 0.0
  let mut x1 = 0.0
  let mut yh = 1.0
  let dithresh = 5.0 * MACHEP
  let mut d = 1.0 / (9.0 * a)
  let mut y = 1.0 - d - ndtri(y0) * d.sqrt()
  let mut x = a * y * y * y
  let lgm = lgamma(a)
  let mut newton_converged = false

  // Newton iteration
  for _ in 0..<10 {
    if x > x0 || x < x1 {
      break
    }
    y = igamc(a, x)
    if y < yl || y > yh {
      break
    }
    if y < y0 {
      x0 = x
      yl = y
    } else {
      x1 = x
      yh = y
    }

    // Compute the derivative of the function at this point
    d = (a - 1.0) * ln(x) - x - lgm
    if d < -MAXLOG {
      break
    }
    d = -exp(d)

    // Compute the step to the next approximation of x
    d = (y - y0) / d
    if (d / x).abs() < MACHEP {
      newton_converged = true
      break
    }
    x -= d
  }

  // If Newton iteration didn't converge, use interval halving
  if not(newton_converged) {
    x = interval_halving(a, y0, x, x0, x1, yl, yh, dithresh)
  }
  // underflow
  if x == 0.0 {
    return @double.not_a_number
  }
  x
}
