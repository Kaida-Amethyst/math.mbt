///|
fn main {
  let x = 1.0
  let y = 5.0
  let cmath_atan2 = @cmath.atan2(x, y)
  let kmath_atan2 = @kmath.atan2(x, y)
  println("cmath atan2(\{x}, \{y}) = \{cmath_atan2}")
  println("kmath atan2(\{x}, \{y}) = \{kmath_atan2}")
}
