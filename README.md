# Moonbit Math Library

[中文版](README-CN.md)

## Overview

The Moonbit Math Library is a comprehensive collection of mathematical functions implemented in the Moonbit programming language. This library is designed to provide high-precision mathematical operations that align closely with the implementations found in the GNU C Library (glibc). It includes a wide range of functions such as trigonometric, exponential, logarithmic, and special functions, all of which are essential for numerical computations.

## Installation

To use the Moonbit Math Library in your project, you can easily add it via the Moonbit package manager. Simply run the following command:

```bash
moon add Kaida-Amethyst/math
```

This command will add the library to your project dependencies, allowing you to import and use the mathematical functions seamlessly.

## Precision

The Moonbit Math Library strives for high precision in its calculations, aiming to match the accuracy of glibc implementations. Below is a table that outlines the ULP (Units in the Last Place) precision differences for each function in the library.

| Function Name | ULP Precision Difference |
|---------------|--------------------------|
| acos          |1                         |
| acosh         |1                         |
| asin          |(TODO)                    |
| asinh         |1                         |
| atan          |(TODO)                    |
| atanh         |1                         |
| cbrt          |1                         |
| ceil          |0                         |
| cos           |2                         |
| cosh          |1                         |
| cospi         |1                         |
| digamma       |7                         |
| erf           |(TODO)                    |
| erfc          |(TODO)                    |
| erfcx         |2                         |
| erfinv        |2                         |
| erfcinv       |(TODO)                    |
| exp           |1                         |
| exp10         |1                         |
| exp2          |1                         |
| expm1         |2                         |
| floor         |0                         |
| hypot         |2                         |
| isinf         |0                         |
| isnan         |0                         |
| isfinite      |0                         |
| j0            |(TODO)                    |
| j1            |(TODO)                    |
| jn            |(TODO)                    |
| log           |1                         |
| log10         |1                         |
| log1p         |1                         |
| log2          |1                         |
| logb          |(TODO)                    |
| lgamma        |(TODO)                    |
| ldexp         |2                         |
| normcdf       |(TODO)                    |
| normcdfinv    |(TODO)                    |
| pow           |2                         |
| pown          |0                         |
| rsqrt         |(TODO)                    |
| rcbrt         |(TODO)                    |
| rint          |(TODO)                    |
| round         |0                         |
| scalbn        |2                         |
| sin           |2                         |
| sinc          |(TODO)                    |
| sinh          |1                         |
| sinhc         |(TODO)                    |
| sinpi         |1                         |
| sincos        |(TODO)                    |
| sincospi      |(TODO)                    |
| sqrt          |1                         |
| tan           |2                         |
| tanh          |1                         |
| trunc         |0                         |
| tgamma        |(TODO)                    |
| y0            |(TODO)                    |
| y1            |(TODO)                    |
| yn            |(TODO)                    |
| zeta          |(TODO)                    |

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
