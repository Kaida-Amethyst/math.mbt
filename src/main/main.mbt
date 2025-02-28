///|
fn main {
  let vals : Array[Float] = [
    0.3, 0.5, 0.8, 0.9,
    // 1.0, 2.0, 3.0, 4.0
  ] 
  fn atanhf(v : Float) -> Float {
    let r = v.to_double() |> @kmath.atanh
    r.to_float()
  }
  // println("test \"sinh\" {")
  for v in vals {
    println("  inspect!((\{v} : Float).atanh(), content=\"\{atanhf(v)}\")")
  }
  // println("}")
}
