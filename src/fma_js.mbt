///|
extern "js" fn __js_fma(a : Double, b : Double, c : Double) -> Double =
  #| (a, b, c) => {
  #|   if (typeof Math.fma === 'function') {
  #|     return Math.fma(a, b, c);
  #|   } else {
  #|     return a * b + c;
  #|   }
  #| }

///|
extern "js" fn __js_fmaf(a : Float, b : Float, c : Float) -> Float =
  #| (a, b, c) => {
  #|   if (typeof Math.fma === 'function') {
  #|     return Math.fma(a, b, c);
  #|   } else {
  #|     return a * b + c;
  #|   }
  #| }

///|
pub fn fma(a : Double, b : Double, c : Double) -> Double {
  __js_fma(a, b, c)
}
