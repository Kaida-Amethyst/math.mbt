// math.h
// sin, cos, tan
// sinh, cosh, tanh
// asin, acos, atan
// asinh, acosh, atanh
// log, log10, log2, log1p
// exp, exp2, expm1
// pow, sqrt, cbrt

pub extern "C" fn sin(x: Double) -> Double = "sin";
pub extern "C" fn cos(x: Double) -> Double = "cos";
pub extern "C" fn tan(x: Double) -> Double = "tan";

pub extern "C" fn sinh(x: Double) -> Double = "sinh";
pub extern "C" fn cosh(x: Double) -> Double = "cosh";
pub extern "C" fn tanh(x: Double) -> Double = "tanh";

pub extern "C" fn asin(x: Double) -> Double = "asin";
pub extern "C" fn acos(x: Double) -> Double = "acos";
pub extern "C" fn atan(x: Double) -> Double = "atan";
pub extern "C" fn atan2(y: Double, x: Double) -> Double = "atan2";

pub extern "C" fn asinh(x: Double) -> Double = "asinh";
pub extern "C" fn acosh(x: Double) -> Double = "acosh";
pub extern "C" fn atanh(x: Double) -> Double = "atanh";

pub extern "C" fn log(x: Double) -> Double = "log";
pub extern "C" fn log10(x: Double) -> Double = "log10";
pub extern "C" fn log2(x: Double) -> Double = "log2";
pub extern "C" fn log1p(x: Double) -> Double = "log1p";

pub extern "C" fn exp(x: Double) -> Double = "exp";
pub extern "C" fn exp2(x: Double) -> Double = "exp2";
pub extern "C" fn expm1(x: Double) -> Double = "expm1";

pub extern "C" fn pow(x: Double, y: Double) -> Double = "pow";
pub extern "C" fn sqrt(x: Double) -> Double = "sqrt";
pub extern "C" fn cbrt(x: Double) -> Double = "cbrt";
