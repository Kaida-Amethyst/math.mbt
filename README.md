# Moonbit Math Library

[中文版](README-CN.md)

## Overview

The Moonbit Math Library is a comprehensive collection of mathematical functions implemented in the Moonbit programming language. This library is designed to provide high-precision mathematical operations that align closely with the implementations found in the GNU C Library (glibc). It includes a wide range of functions such as trigonometric, exponential, logarithmic, and special functions, all of which are essential for numerical computations.

## Installation

To use the Moonbit Math Library in your project, you can easily add it via the Moonbit package manager. Simply run the following command:

```bash
moon add KaidaAmethyst/moonbit-math
```

This command will add the library to your project dependencies, allowing you to import and use the mathematical functions seamlessly.

## Precision

The Moonbit Math Library strives for high precision in its calculations, aiming to match the accuracy of glibc implementations. Below is a table that outlines the ULP (Units in the Last Place) precision differences for each function in the library.

| Function Name | ULP Precision Difference |
|---------------|--------------------------|
| acos          |                          |
| acosh         |                          |
| asin          |                          |
| asinh         |                          |
| atan          |                          |
| atanh         |                          |
| cbrt          |                          |
| ceil          |                          |
| cos           |                          |
| cosh          |                          |
| erf           |                          |
| erfinv        |                          |
| exp           |                          |
| exp10         |                          |
| exp2          |                          |
| expm1         |                          |
| floor         |                          |
| hypot         |                          |
| isinf         |                          |
| isnan         |                          |
| log           |                          |
| log10         |                          |
| log1p         |                          |
| log2          |                          |
| pow           |                          |
| rsqrt         |                          |
| round         |                          |
| scalbn        |                          |
| sin           |                          |
| sinh          |                          |
| sqrt          |                          |
| tan           |                          |
| tanh          |                          |
| trunc         |                          |

### Notes on Precision

- **ULP (Units in the Last Place)**: This metric measures the difference between the computed result and the true result in terms of the least significant bit of the floating-point representation. A lower ULP value indicates higher precision.
- **0 ULP**: Indicates that the function matches the glibc implementation exactly.
- **1 ULP**: Indicates that the function is within half a unit of the last place, which is considered very high precision.
- **2 ULP**: Indicates that the function is within one unit of the last place, which is still considered acceptable for most numerical applications.

## Usage Example

Here is a simple example demonstrating how to use the `sin` function from the Moonbit Math Library:

```moonbit
import math

fn main() {
    let angle = 1.0 // in radians
    let result = math.sin(angle)
    println("The sine of \(angle) is \(result)")
}
```

## Contributing

We welcome contributions to the Moonbit Math Library! If you find any issues or have suggestions for improvements, please feel free to open an issue or submit a pull request on our [GitHub repository](https://github.com/KaidaAmethyst/moonbit-math).

## License

The Moonbit Math Library is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

---

Thank you for using the Moonbit Math Library! We hope it serves you well in your numerical computing endeavors.
