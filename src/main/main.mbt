fn main {
  let x = 3.8
  let ky = @kmath.log1p(x)
  let iky = BigInt::from_uint64(ky.reinterpret_as_uint64()).to_hex(uppercase=false)
  println("kmath log1p(\{x}) = \{ky}(\{iky})")
}
