///|
pub fn pdtr(k : Int, m : Double) -> Double {
  if k < 0 || m <= 0.0 {
    return @double.not_a_number
  }
  let v = (k + 1).to_double()
  igamc(v, m)
}
