///|
pub trait Floating {
  // Algebraic
  abs(Self) -> Self
  sqrt(Self) -> Self
  cbrt(Self) -> Self
  hypot(Self, Self) -> Self
  ldexp(Self, Int) -> Self
  scalbn(Self, Int) -> Self

  // Trig
  sin(Self) -> Self
  cos(Self) -> Self
  tan(Self) -> Self

  // Inverse Trig
  asin(Self) -> Self
  acos(Self) -> Self
  atan(Self) -> Self

  // Hyperbolic
  sinh(Self) -> Self
  cosh(Self) -> Self
  tanh(Self) -> Self

  // Inverse Hyperbolic
  asinh(Self) -> Self
  acosh(Self) -> Self
  atanh(Self) -> Self

  // Log
  log(Self) -> Self
  ln(Self) -> Self
  log2(Self) -> Self
  log10(Self) -> Self
  log1p(Self) -> Self
  ln_1p(Self) -> Self

  // Exp
  exp(Self) -> Self
  exp2(Self) -> Self
  exp10(Self) -> Self
  expm1(Self) -> Self

  // TODO:...
}

pub impl Floating for Double with abs(self) {
  fabs(self)
}

pub impl Floating for Double with sqrt(self) {
  self.sqrt()
}

pub impl Floating for Double with cbrt(self) {
  cbrt(self)
}

pub impl Floating for Double with hypot(self, y) {
  hypot(self, y)
}

pub impl Floating for Double with ldexp(self, n: Int) {
  ldexp(self, n)
}

pub impl Floating for Double with scalbn(self, n: Int) {
  scalbn(self, n)
}


///|
pub impl Floating for Double with sin(self) -> Double {
  sin(self)
}

///|
pub impl Floating for Double with cos(self) -> Double {
  cos(self)
}

///|
pub impl Floating for Double with tan(self) -> Double {
  tan(self)
}


///|
pub impl Floating for Double with asin(self) -> Double {
  asin(self)
}

///|
pub impl Floating for Double with acos(self) -> Double {
  acos(self)
}

///|
pub impl Floating for Double with atan(self) -> Double {
  atan(self)
}

///|
pub impl Floating for Double with sinh(self) -> Double {
  sinh(self)
}

///|
pub impl Floating for Double with cosh(self) -> Double {
  cosh(self)
}

///|
pub impl Floating for Double with tanh(self) -> Double {
  tanh(self)
}

///|
pub impl Floating for Double with asinh(self) -> Double {
  asinh(self)
}

///|
pub impl Floating for Double with acosh(self) -> Double {
  acosh(self)
}

///|
pub impl Floating for Double with atanh(self) -> Double {
  atanh(self)
}

pub impl Floating for Double with log(self) {
  log(self)
}

pub impl Floating for Double with ln(self) {
  ln(self)
}

pub impl Floating for Double with log2(self) {
  log2(self)
}

pub impl Floating for Double with log10(self) {
  log10(self)
}

pub impl Floating for Double with log1p(self) {
  log1p(self)
}

pub impl Floating for Double with ln_1p(self) {
  ln_1p(self)
}

pub impl Floating for Double with exp(self) {
  exp(self)
}

pub impl Floating for Double with exp2(self) {
  exp2(self)
}

pub impl Floating for Double with exp10(self) {
  exp10(self)
}

pub impl Floating for Double with expm1(self) {
  expm1(self)
}
