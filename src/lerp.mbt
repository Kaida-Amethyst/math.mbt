///| Compute the linear interpolation between two values
pub fn lerp(a: Double, b: Double, t: Double) -> Double {
    a + (b - a) * t
}
