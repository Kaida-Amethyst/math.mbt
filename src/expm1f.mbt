const O_THRESHOLD: Float = 8.8721679688e+01; // 0x42b17180
const INV_LN2: Float = 1.4426950216e+00; // 0x3fb8aa3b
//
// Domain [-0.34568, 0.34568], range ~[-6.694e-10, 6.696e-10]:
// |6 / x * (1 + 2 * (1 / (exp(x) - 1) - 1 / x)) - q(x)| < 2**-30.04
// Scaled coefficients: Qn_here = 2**n * Qn_for_q (see s_expm1.c):
//

/// Exponential, base *e*, of x-1 (Float)
///
/// Calculates the exponential of `x` and subtract 1, that is, *e* raised
/// to the power `x` minus 1 (where *e* is the base of the natural
/// system of logarithms, approximately 2.71828).
/// The result is accurate even for small values of `x`,
/// where using `exp(x)-1` would lose many significant digits.
pub fn expm1f(x: Float) -> Float {
    let mut x = x;

    let q1: Float = -3.3333212137e-2; // -0x888868.0p-28
    let q2: Float = 1.5807170421e-3; //  0xcf3010.0p-33

    let mut hx = x.reinterpret_as_uint();
    let sign = (hx >> 31) != 0;
    hx = hx & 0x7fffffff;

    // filter out huge and non-finite argument
    if hx >= 0x4195b844 {
        // if |x|>=27*ln2
        if hx > 0x7f800000 {
            // NaN
            return x;
        }
        if sign {
            return -1.;
        }
        if x > O_THRESHOLD {
            x *= (0x1.0p127 : Float);
            return x;
        }
    }

    let mut k: Int = 0;
    let mut hi: Float = 0;
    let mut lo: Float = 0;
    let mut c : Float = 0;
    // argument reduction
    if hx > 0x3eb17218 {
        // if  |x| > 0.5 ln2
        if hx < 0x3F851592 {
            // and |x| < 1.5 ln2
            if not(sign) {
                hi = x - FLOAT_LN2_HI;
                lo = FLOAT_LN2_LO;
                k = 1;
            } else {
                hi = x + FLOAT_LN2_HI;
                lo = -FLOAT_LN2_LO;
                k = -1;
            }
        } else {
            k = (INV_LN2 * x + (if sign { -0.5 } else { 0.5 })).to_int();
            let t = k.to_float();
            hi = x - t * FLOAT_LN2_HI; // t*ln2_hi is exact here
            lo = t * FLOAT_LN2_LO;
        }
        x = hi - lo;
        c = (hi - x) - lo;
    } else if hx < 0x33000000 {
        // when |x|<2**-25, return x
        //if hx < 0x00800000 {
        //    force_eval!(x * x);
        //}
        return x;
    } else {
        k = 0;
    }

    // x is now in primary range
    let hfx = (0.5 : Float) * x;
    let hxs = x * hfx;
    let r1 = (1.0 : Float) + hxs * (q1 + hxs * q2);
    let t = (3.0 : Float) - r1 * hfx;
    let mut e = hxs * ((r1 - t) / ((6.0 : Float) - x * t));
    if k == 0 {
        // c is 0
        return x - (x * e - hxs);
    }
    e = x * (e - c) - c;
    e -= hxs;
    // exp(x) ~ 2^k (x_reduced - e + 1)
    if k == -1 {
        return (0.5:Float) * (x - e) - 0.5;
    }
    if k == 1 {
        if x < -0.25 {
            return -(2.0 : Float) * (e - (x + 0.5));
        }
        return (1.0:Float) + (2.0:Float) * (x - e);
    }
    let twopk = ((0x7f + k) << 23).reinterpret_as_float(); // 2^k
    if not(k is 0..=56) {
        // suffice to return exp(x)-1
        let mut y = x - e + 1.;
        if k == 128 {
            y = y * 2. * (0x1.0p127 : Float);
        } else {
            y = y * twopk;
        }
        return y - 1.;
    }
    let uf = ((0x7f - k) << 23).reinterpret_as_float(); // 2^-k
    if k < 23 { (x - e + ((1.0 : Float)- uf)) * twopk } else { (x - (e + uf) + 1.) * twopk }
}
