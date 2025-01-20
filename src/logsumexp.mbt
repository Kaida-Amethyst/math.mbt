///| Return the log of the sum of exponentials of the elements of the input array.
/// # Introduction
///
/// logsumexp(x) returns the natural logarithm of the sum of the exponentials of the elements of the input array x.
/// See: https://nhigham.com/2021/01/05/what-is-the-log-sum-exp-function/
/// to get more information.
pub fn logsumexp(elements : Array[Double]) -> Double {
  let (max_val, idx) = max_element(elements)
  let mut result = 0.0
  for i, v in elements {
    if i != idx {
      result += exp(v - max_val)
    }
  }
  max_val + log1p(result)
}
