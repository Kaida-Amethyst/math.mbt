// template <typename T>
// T bessel_k0_imp(const T& x, const std::integral_constant<int, 53>&)
// {
//    BOOST_MATH_STD_USING
//    if(x <= 1)
//    {
//       // Maximum Deviation Found:                     6.077e-17
//       // Expected Error Term : -6.077e-17
//       // Maximum Relative Change in Control Points : 7.797e-02
//       // Max Error found at double precision = Poly : 1.003156e-16
//       static const T Y = 1.137250900268554688;
//       static const T P[] =
//       {
//          -1.372509002685546267e-01,
//          2.574916117833312855e-01,
//          1.395474602146869316e-02,
//          5.445476986653926759e-04,
//          7.125159422136622118e-06
//       };
//       static const T Q[] =
//       {
//          1.000000000000000000e+00,
//          -5.458333438017788530e-02,
//          1.291052816975251298e-03,
//          -1.367653946978586591e-05
//       };
//
//       T a = x * x / 4;
//       a = (tools::evaluate_polynomial(P, a) / tools::evaluate_polynomial(Q, a) + Y) * a + 1;
//
//       // Maximum Deviation Found:                     3.429e-18
//       // Expected Error Term : 3.392e-18
//       // Maximum Relative Change in Control Points : 2.041e-02
//       // Max Error found at double precision = Poly : 2.513112e-16
//       static const T P2[] =
//       {
//          1.159315156584124484e-01,
//          2.789828789146031732e-01,
//          2.524892993216121934e-02,
//          8.460350907213637784e-04,
//          1.491471924309617534e-05,
//          1.627106892422088488e-07,
//          1.208266102392756055e-09,
//          6.611686391749704310e-12
//       };
//
//       return tools::evaluate_polynomial(P2, T(x * x)) - log(x) * a;
//    }
//    else
//    {
//       // Maximum Deviation Found:                     4.316e-17
//       // Expected Error Term : 9.570e-18
//       // Maximum Relative Change in Control Points : 2.757e-01
//       // Max Error found at double precision = Poly : 1.001560e-16
//
//       static const T Y = 1;
//       static const T P[] =
//       {
//          2.533141373155002416e-01,
//          3.628342133984595192e+00,
//          1.868441889406606057e+01,
//          4.306243981063412784e+01,
//          4.424116209627428189e+01,
//          1.562095339356220468e+01,
//          -1.810138978229410898e+00,
//          -1.414237994269995877e+00,
//          -9.369168119754924625e-02
//       };
//       static const T Q[] =
//       {
//          1.000000000000000000e+00,
//          1.494194694879908328e+01,
//          8.265296455388554217e+01,
//          2.162779506621866970e+02,
//          2.845145155184222157e+02,
//          1.851714491916334995e+02,
//          5.486540717439723515e+01,
//          6.118075837628957015e+00,
//          1.586261269326235053e-01
//       };
//       if(x < tools::log_max_value<T>())
//          return ((tools::evaluate_rational(P, Q, T(1 / x)) + Y) * exp(-x) / sqrt(x));
//       else
//       {
//          T ex = exp(-x / 2);
//          return ((tools::evaluate_rational(P, Q, T(1 / x)) + Y) * ex / sqrt(x)) * ex;
//       }
//    }
// }
//
