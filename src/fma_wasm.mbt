extern "wasm" fn __wasm_fma(a: Double, b: Double, c: Double) -> Double =
  #| (func (param f64) (param f64) (param f64) (result f64)
  #|   (f64.fma (local.get 0) (local.get 1) (local.get 2))
  #| )

extern "wasm" fn __wasm_fmaf(a: Float, b: Float, c: Float) -> Float = 
  #| (func (param f32) (param f32) (param f32) (result f32)
  #|   (f32.fma (local.get 0) (local.get 1) (local.get 2))
  #| )

pub fn fma(a: Double, b: Double, c: Double) -> Double {
  __wasm_fma(a, b, c)
}
