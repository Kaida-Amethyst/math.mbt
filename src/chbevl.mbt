// template<typename T>
// T chbevl(const T x, const T array[], const int len) {
//     T b0, b1, b2;
//
//     b0 = array[0];
//     b1 = 0;
//
//     for (int i = 1; i < len; ++i)  {
//         b2 = b1;
//         b1 = b0;
//         b0 = x * b1 - b2 + array[i];
//     }
//
//     return T{0.5} * (b0 - b2);
// }

///| Computes the Chebyshev series
pub fn chbevl(x : Double, arr : Array[Double]) -> Double {
  let mut b0 = arr[0]
  let mut b1 = 0.0
  let mut b2 = 0.0
  for i = 1; i < arr.length(); i = i + 1 {
    b2 = b1
    b1 = b0
    b0 = x * b1 - b2 + arr[i]
  }
  0.5 * (b0 - b2)
}
