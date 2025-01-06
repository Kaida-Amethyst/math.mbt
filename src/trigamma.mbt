//     macro_rules! evaluate_polynomial(
//     ($x:expr, $coefficients:expr) => (
//         $coefficients.iter().rev().fold(0.0, |sum, &c| $x * sum + c)
//     );
// );
// fn trigamma(&self) -> Self {
//     let mut x: $kind = *self;
//     if x <= 0.0 {
//         return (<$kind>::PI * (<$kind>::PI * x).sin().recip()).powi(2)
//             - (1.0 - x).trigamma();
//     }
//
//     let mut psi: $kind = 0.0;
//     if x < 8.0 {
//         let n = (8.0 - x.floor()) as usize;
//         psi += x.recip().powi(2);
//         for v in 1..n {
//             psi += (x + (v as $kind)).recip().powi(2);
//         }
//         x += n as $kind;
//     }
//     let t = x.recip();
//     let w = t * t;
//     psi += t + 0.5 * w;
//     psi + t
//         * w
//         * evaluate_polynomial!(
//             w,
//             [
//                 0.16666666666666666,
//                 -0.03333333333333333,
//                 0.023809523809523808,
//                 -0.03333333333333333,
//                 0.07575757575757576,
//                 -0.2531135531135531,
//                 1.1666666666666667,
//                 -7.092156862745098,
//             ]
//         )
// }

///| Computes the trigamma function of `x`.
pub fn trigamma(x: Double) -> Double {
    let mut sign = 1.0;
    let mut result = 0.0;
    let mut x = x;

    if x < 0.5 {
        sign = -1.0;
        let sin_pi_x = sinpi(x)
        result -= (PI * PI) / (sin_pi_x * sin_pi_x);
        x = 1.0 - x;
    }

    for i=0; i < 6; i = i+1 {
        result += 1.0 / (x * x);
        x += 1.0;
    }

    let one = 1.0;
    let ixx = one / (x * x);
    result += (one + one / (2.0 * x) + ixx * (one / 6.0 - ixx * (one / 30.0 - ixx * (one / 42.0)))) / x;

    sign * result
}
