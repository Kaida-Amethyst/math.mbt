///|
pub fn pdtri(k : Int, y : Double) -> Double {
  if k < 0 || y < 0.0 || y >= 1.0 {
    return @double.not_a_number
  }
  let v = (k + 1).to_double()
  igami(v, y)
}
