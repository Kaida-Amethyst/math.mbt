// template <typename T>
//   T bessel_k1_imp(const T& x, const std::integral_constant<int, 53>&)
//   {
//      BOOST_MATH_STD_USING
//      if(x <= 1)
//      {
//         // Maximum Deviation Found:                     1.922e-17
//         // Expected Error Term : 1.921e-17
//         // Maximum Relative Change in Control Points : 5.287e-03
//         // Max Error found at double precision = Poly : 2.004747e-17
//         static const T Y = 8.69547128677368164e-02f;
//         static const T P[] =
//         {
//            -3.62137953440350228e-03,
//            7.11842087490330300e-03,
//            1.00302560256614306e-05,
//            1.77231085381040811e-06
//         };
//         static const T Q[] =
//         {
//            1.00000000000000000e+00,
//            -4.80414794429043831e-02,
//            9.85972641934416525e-04,
//            -8.91196859397070326e-06
//         };
//
//         T a = x * x / 4;
//         a = ((tools::evaluate_rational(P, Q, a) + Y) * a * a + a / 2 + 1) * x / 2;
//
//         // Maximum Deviation Found:                     4.053e-17
//         // Expected Error Term : -4.053e-17
//         // Maximum Relative Change in Control Points : 3.103e-04
//         // Max Error found at double precision = Poly : 1.246698e-16
//
//         static const T P2[] =
//         {
//            -3.07965757829206184e-01,
//            -7.80929703673074907e-02,
//            -2.70619343754051620e-03,
//            -2.49549522229072008e-05
//         };
//         static const T Q2[] = 
//         {
//            1.00000000000000000e+00,
//            -2.36316836412163098e-02,
//            2.64524577525962719e-04,
//            -1.49749618004162787e-06
//         };
//
//         return tools::evaluate_rational(P2, Q2, T(x * x)) * x + 1 / x + log(x) * a;
//      }
//      else
//      {
//         // Maximum Deviation Found:                     8.883e-17
//         // Expected Error Term : -1.641e-17
//         // Maximum Relative Change in Control Points : 2.786e-01
//         // Max Error found at double precision = Poly : 1.258798e-16
//
//         static const T Y = 1.45034217834472656f;
//         static const T P[] =
//         {
//            -1.97028041029226295e-01,
//            -2.32408961548087617e+00,
//            -7.98269784507699938e+00,
//            -2.39968410774221632e+00,
//            3.28314043780858713e+01,
//            5.67713761158496058e+01,
//            3.30907788466509823e+01,
//            6.62582288933739787e+00,
//            3.08851840645286691e-01
//         };
//         static const T Q[] =
//         {
//            1.00000000000000000e+00,
//            1.41811409298826118e+01,
//            7.35979466317556420e+01,
//            1.77821793937080859e+02,
//            2.11014501598705982e+02,
//            1.19425262951064454e+02,
//            2.88448064302447607e+01,
//            2.27912927104139732e+00,
//            2.50358186953478678e-02
//         };
//         if(x < tools::log_max_value<T>())
//            return ((tools::evaluate_rational(P, Q, T(1 / x)) + Y) * exp(-x) / sqrt(x));
//         else
//         {
//            T ex = exp(-x / 2);
//            return ((tools::evaluate_rational(P, Q, T(1 / x)) + Y) * ex / sqrt(x)) * ex;
//         }
//      }
//   }
//
