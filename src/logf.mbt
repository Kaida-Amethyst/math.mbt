const LN2_HI_F: Float = 6.9313812256e-01;
const LN2_LO_F: Float = 9.0580006145e-06;
const LG1_F: Float = 0.66666662693;
const LG2_F: Float = 0.40000972152;
const LG3_F: Float = 0.28498786688;
const LG4_F: Float = 0.24279078841;

pub fn logf(x: Float) -> Float {
    let mut x = x; 
    let x1p25 = (0x4c000000).reinterpret_as_float();

    let mut ix = x.reinterpret_as_int();
    let mut k = 0;

    if (ix < 0x00800000) || ((ix >> 31) != 0) {
        if ix << 1 == 0 {
            return (-1.0 : Float) / (x * x);
        }
        if (ix >> 31) != 0 {
            return (x - x) / 0.;
        }
        k -= 25;
        x *= x1p25;
        ix = x.reinterpret_as_int();
    } else if ix >= 0x7f800000 {
        return x;
    } else if ix == 0x3f800000 {
        return 0.;
    }

    ix += 0x3f800000 - 0x3f3504f3;
    k += ((ix >> 23)) - 0x7f;
    ix = (ix & 0x007fffff) + 0x3f3504f3;
    x = ix.reinterpret_as_float();

    let f = x - 1.;
    let s = f / ((2. : Float) + f);
    let z = s * s;
    let w = z * z;
    let t1 = w * (LG2_F + w * LG4_F);
    let t2 = z * (LG1_F + w * LG3_F);
    let r = t2 + t1;
    let hfsq = (0.5 : Float) * f * f;
    let dk = k.to_float();
    s * (hfsq + r) + dk * LN2_LO_F - hfsq + f + dk * LN2_HI_F
}
