# Moonbit Math Library

[中文版](README-CN.md)

## Overview

The Moonbit Math Library is a comprehensive collection of mathematical functions implemented in the Moonbit programming language. This library is designed to provide high-precision mathematical operations that align closely with the implementations found in the GNU C Library (glibc). It includes a wide range of functions such as trigonometric, exponential, logarithmic, and special functions, all of which are essential for numerical computations.

## Installation

To use the Moonbit Math Library in your project, you can easily add it via the Moonbit package manager. Simply run the following command:

```bash
moon add Kaida-Amethyst/moonbit-math
```

This command will add the library to your project dependencies, allowing you to import and use the mathematical functions seamlessly.

## Precision

The Moonbit Math Library strives for high precision in its calculations, aiming to match the accuracy of glibc implementations. Below is a table that outlines the ULP (Units in the Last Place) precision differences for each function in the library.

| func          | description                          | ulp (for result is float or double) |
|---------------|--------------------------------------|-------------------------------------|
| abs           | Compute absolute value               | TODO                                |
| acos          | Compute arccosine                    | TODO                                |
| acosh         | Compute inverse hyperbolic cosine    | TODO                                |
| asin          | Compute arcsine                      | TODO                                |
| asinh         | Compute inverse hyperbolic sine      | TODO                                |
| atan          | Compute arctangent                   | TODO                                |
| atan2         | Compute arctangent with two arguments| TODO                                |
| atanh         | Compute inverse hyperbolic tangent   | TODO                                |
| cbrt          | Compute cubic root                   | TODO                                |
| ceil          | Round up to the nearest integer      | TODO                                |
| clamp         | Clamp value within a specified range  | TODO                               |
| constants     | Mathematical constants               | TODO                                |
| cos           | Compute cosine                       | TODO                                |
| cosh          | Compute hyperbolic cosine            | TODO                                |
| cospi         | Compute cos(πx)                      | TODO                                |
| digamma       | Compute Digamma function             | TODO                                |
| div_euclid    | Compute Euclidean division           | TODO                                |
| erf           | Compute error function               | TODO                                |
| erfc          | Compute complementary error function | TODO                                |
| erfcinv       | Compute inverse complementary error function | TODO                        |
| erfcx         | Compute scaled complementary error function | TODO                         |
| erfinv        | Compute inverse error function       | TODO                                |
| exp           | Compute exponential function         | TODO                                |
| exp10         | Compute 10 raised to the power of x  | TODO                                |
| exp2          | Compute 2 raised to the power of x   | TODO                                |
| expm1         | Compute exp(x) - 1                   | TODO                                |
| fast_rsqrt    | Compute fast reciprocal square root  | TODO                                |
| floor         | Round down to the nearest integer    | TODO                                |
| fract         | Compute fractional part              | TODO                                |
| fdim          | Compute positive difference of two numbers | TODO                          |
| gelu          | Compute GELU function                | TODO                                |
| gegenbauer    | Compute Gegenbauer polynomial        | TODO                                |
| gamma         | Compute Gamma function               | TODO                                |
| hermite       | Compute Hermite polynomial           | TODO                                |
| hypot         | Compute Euclidean norm               | TODO                                |
| ilogb         | Compute integer part of log2(x)      | TODO                                |
| isfinite      | Check if value is finite             | TODO                                |
| isinf         | Check if value is infinite           | TODO                                |
| isnan         | Check if value is NaN                | TODO                                |
| isnormal      | Check if value is normal             | TODO                                |
| issubnormal   | Check if value is subnormal          | TODO                                |
| jacobi        | Compute Jacobi elliptic function     | TODO                                |
| j0            | Compute Bessel function of the first kind (0th order) | TODO               |
| j1            | Compute Bessel function of the first kind (1st order) | TODO               |
| jn            | Compute Bessel function of the first kind (nth order) | TODO               |
| ldexp         | Compute x * 2^exp                    | TODO                                |
| log           | Compute natural logarithm            | TODO                                |
| log10         | Compute logarithm base 10            | TODO                                |
| log1p         | Compute log(1 + x)                   | TODO                                |
| log2          | Compute logarithm base 2             | TODO                                |
| logaddexp     | Compute log(exp(x) + exp(y))         | TODO                                |
| logb          | Compute integer part of log2(x)      | TODO                                |
| logsumexp     | Compute log(sum(exp(x)))             | TODO                                |
| nearbyint     | Round to nearest integer             | TODO                                |
| nextafter     | Return next floating-point number    | TODO                                |
| nextdown      | Return next smaller floating-point number | TODO                           |
| nextup        | Return next larger floating-point number | TODO                            |
| norm          | Compute norm                         | TODO                                |
| normcdf       | Compute cumulative distribution function of normal distribution | TODO     |
| normcdfinv    | Compute inverse cumulative distribution function of normal distribution | TODO |
| pown          | Compute integer power of x           | TODO                                |
| polygamma     | Compute Polygamma function           | TODO                                |
| pow           | Compute x raised to the power of y   | TODO                                |
| rcbrt         | Compute reciprocal of cubic root     | TODO                                |
| rem_euclid    | Compute Euclidean remainder          | TODO                                |
| rhypot        | Compute reciprocal of Euclidean norm | TODO                                |
| rint          | Round to nearest integer             | TODO                                |
| rnorm         | Compute reciprocal of norm           | TODO                                |
| round         | Round to nearest integer             | TODO                                |
| roundeven     | Round to nearest even integer        | TODO                                |
| rsqrt         | Compute reciprocal of square root    | TODO                                |
| scalbn        | Compute x * 2^n                      | TODO                                |
| sign          | Compute sign function                | TODO                                |
| signum        | Compute sign function                | TODO                                |
| sin           | Compute sine                         | TODO                                |
| sinc          | Compute sinc function                | TODO                                |
| sincos        | Compute sine and cosine simultaneously | TODO                              |
| sincospi      | Compute sin(πx) and cos(πx) simultaneously | TODO                          |
| sinh          | Compute hyperbolic sine              | TODO                                |
| sinhc         | Compute normalized hyperbolic sine   | TODO                                |
| sinpi         | Compute sin(πx)                      | TODO                                |
| sqrt          | Compute square root                  | TODO                                |
| sqrt1pm1      | Compute sqrt(1 + x) - 1              | TODO                                |
| tan           | Compute tangent                      | TODO                                |
| tanh          | Compute hyperbolic tangent           | TODO                                |
| to_degrees    | Convert radians to degrees           | TODO                                |
| to_radians    | Convert degrees to radians           | TODO                                |
| trunc         | Truncate to integer part             | TODO                                |
| utils         | Utility functions                    | TODO                                |
| y0            | Compute Bessel function of the second kind (0th order) | TODO              |
| y1            | Compute Bessel function of the second kind (1st order) | TODO              |
| yn            | Compute Bessel function of the second kind (nth order) | TODO              |
| zeta          | Compute Riemann zeta function        | TODO                                |

### Notes on Precision

- **ULP (Units in the Last Place)**: This metric measures the difference between the computed result and the true result in terms of the least significant bit of the floating-point representation. A lower ULP value indicates higher precision.
- **0 ULP**: Indicates that the function matches the glibc implementation exactly.
- **1 ULP**: Indicates that the function is within half a unit of the last place, which is considered very high precision.
- **2 ULP**: Indicates that the function is within one unit of the last place, which is still considered acceptable for most numerical applications.

## Usage Example

Here is a simple example demonstrating how to use the `sin` function from the Moonbit Math Library:

First add dependencies in `moon.pkg.json`:

```json
{
    "import" :[
        ...
        "Kaida-Amethyst/math"
    ]
}
```

Then you can use math functions, for example:

```moonbit
fn main() {
    let angle = 1.0 // in radians
    let result = @math.sin(angle)
    println("The sine of \{angle} is \{result}")
}
```

## Contributing

We welcome contributions to the Moonbit Math Library! If you find any issues or have suggestions for improvements, please feel free to open an issue or submit a pull request on our [GitHub repository](https://github.com/Kaida-Amethyst/moonbit-math).

## License

The Moonbit Math Library is licensed under the Apache-2.0 License. See the [LICENSE](LICENSE) file for more details.

---

Thank you for using the Moonbit Math Library! We hope it serves you well in your numerical computing endeavors.
