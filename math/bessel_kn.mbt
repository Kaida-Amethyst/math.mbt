// template <typename T, typename Policy>
// T bessel_kn(int n, T x, const Policy& pol)
// {
//     BOOST_MATH_STD_USING
//     T value, current, prev;
//
//     using namespace boost::math::tools;
//
//     static const char* function = "boost::math::bessel_kn<%1%>(%1%,%1%)";
//
//     if (x < 0)
//     {
//        return policies::raise_domain_error<T>(function,
//             "Got x = %1%, but argument x must be non-negative, complex number result not supported.", x, pol);
//     }
//     if (x == 0)
//     {
//        return policies::raise_overflow_error<T>(function, nullptr, pol);
//     }
//
//     if (n < 0)
//     {
//         n = -n;                             // K_{-n}(z) = K_n(z)
//     }
//     if (n == 0)
//     {
//         value = bessel_k0(x);
//     }
//     else if (n == 1)
//     {
//         value = bessel_k1(x);
//     }
//     else
//     {
//        prev = bessel_k0(x);
//        current = bessel_k1(x);
//        int k = 1;
//        BOOST_MATH_ASSERT(k < n);
//        T scale = 1;
//        do
//        {
//            T fact = 2 * k / x;
//            if((tools::max_value<T>() - fabs(prev)) / fact < fabs(current))
//            {
//               scale /= current;
//               prev /= current;
//               current = 1;
//            }
//            value = fact * current + prev;
//            prev = current;
//            current = value;
//            ++k;
//        }
//        while(k < n);
//        if(tools::max_value<T>() * scale < fabs(value))
//           return sign(scale) * sign(value) * policies::raise_overflow_error<T>(function, nullptr, pol);
//        value /= scale;
//     }
//     return value;
// }
//
