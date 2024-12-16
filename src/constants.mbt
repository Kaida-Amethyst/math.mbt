
pub const RADIX: UInt = 2U;
pub const MANTISSA_DIGITS: UInt = 53U;
pub const DIGITS: UInt = 15U;

///| Epsilon is the minimum value that make double `1.0 + epsilon != 1.0`
pub const DOUBLE_EPSILON : Double = 2.2204460492503131e-16;

///| The smallest positive value that can be represented by a double.
pub const DOUBLE_MIN: Double = -1.7976931348623157E+308

///| The smallest positive value that can be represented by a double.
pub const DOUBLE_MIN_POSITIVE: Double = 2.2250738585072014E-308

///| The largest positive value that can be represented by a double.
pub const DOUBLE_MAX: Double = 1.7976931348623157E+308

///| The minimum exponent a normalized double can have (IEEE 754).
pub const DOUBLE_MIN_EXP: Int = -1021;

///| The maximum exponent a normalized double can have (IEEE 754).
pub const DOUBLE_MAX_EXP: Int = 1024;

///| The minimum exponent a normalized double can have (base 10).
pub const DOUBLE_MIN_10_EXP: Int = -307;

///| The maximum exponent a normalized double can have (base 10).
pub const DOUBLE_MAX_10_EXP: Int = 308;

///| Nature Exponent
pub const E: Double = 2.7182818284590452354;

///| The ratio of the circumference of a circle to its diameter.
pub const PI: Double = 3.14159265358979323846;

///| PI/2
pub const PI_OVER_2: Double = 1.57079632679489661923;

///| PI/4
pub const PI_OVER_4: Double = 0.785398163397448309616;

///| 1/PI
pub const ONE_OVER_PI: Double = 0.318309886183790671538;

///| 2/PI
pub const TWO_OVER_PI: Double = 0.636619772367581343076;

///| 1/sqrt(PI)
pub const INV_SQRT_PI: Double = 0.564189583547756286948;

///| 2/sqrt(PI)
pub const TWO_OVER_SQRTPI: Double = 1.12837916709551257390;

///| sqrt(2)
pub const SQRT2: Double = 1.41421356237309504880;

///| 1/sqrt(2)
pub const SQRT1_OVER_2: Double = 0.707106781186547524401;

///| ln(2)
pub const LN2: Double = 0.693147180559945309417;

///| ln(10)
pub const LN10: Double = 2.30258509299404568402;

///| log2(e)
pub const LOG2E: Double = 1.44269504088896340736;

///| log10(e)
pub const LOG10E: Double = 0.434294481903251827651;

// The speed of light in vacuum, in meters per second.
// pub const C: Double = 299792458.0;
