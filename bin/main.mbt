///|
fn main {
  let vals : Array[Float] = [
    1.45, 2.55, 3.65, 4.75
  ] 
  fn hypotf(v : Float) -> Float {
    let r = v.to_double() |> @kmath.hypot(2.5)
    r.to_float()
  }
  println("text \"hypot\" {")
  for v in vals {
    println("  inspect!((\{v} : Float).hypot(2.5), content=\"\{hypotf(v)}\")")
  }
  println("}")
}
