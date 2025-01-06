  // template <typename T>
  // T log_ndtr(T x) {
  //   constexpr T SQRT1_2{0.707106781186547524400844362104849039};   // 1/sqrt(2)
  //   T t = x * SQRT1_2;
  //   if (x < T{-1.0}) {
  //     return log(erfcx(-t) / 2) - t * t;
  //   } else {
  //     return log1p(-erfc(t) / 2);
  //   }
  // }
