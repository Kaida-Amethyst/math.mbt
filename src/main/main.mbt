///|
fn main {
  let x = 3.8
  let ky = @kmath.log1p(x)
  let iky = BigInt::from_uint64(ky.reinterpret_as_uint64()).to_hex(
    uppercase=false,
  )
  println("kmath log1p(\{x}) = \{ky}(\{iky})")

  // let ieee754_one = 1.0.reinterpret_as_int64().to_hex()
  let ieee754_one = BigInt::from_int64(1.0.reinterpret_as_int64()).to_hex()
  println("ieee754_one = 0x\{ieee754_one}")
}
