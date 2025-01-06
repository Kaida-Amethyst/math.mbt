// /* __ieee754_hypot(x,y)
//  *
//  * Method :                  
//  *	If (assume round-to-nearest) z=x*x+y*y 
//  *	has error less than sqrt(2)/2 ulp, than 
//  *	sqrt(z) has error less than 1 ulp (exercise).
//  *
//  *	So, compute sqrt(x*x+y*y) with some care as 
//  *	follows to get the error below 1 ulp:
//  *
//  *	Assume x>y>0;
//  *	(if possible, set rounding to round-to-nearest)
//  *	1. if x > 2y  use
//  *		x1*x1+(y*y+(x2*(x+x1))) for x*x+y*y
//  *	where x1 = x with lower 32 bits cleared, x2 = x-x1; else
//  *	2. if x <= 2y use
//  *		t1*y1+((x-y)*(x-y)+(t1*y2+t2*y))
//  *	where t1 = 2x with lower 32 bits cleared, t2 = 2x-t1, 
//  *	y1= y with lower 32 bits chopped, y2 = y-y1.
//  *		
//  *	NOTE: scaling may be necessary if some argument is too 
//  *	      large or too tiny
//  *
//  * Special cases:
//  *	hypot(x,y) is INF if x or y is +INF or -INF; else
//  *	hypot(x,y) is NAN if x or y is NAN.
//  *
//  * Accuracy:
//  * 	hypot(x,y) returns sqrt(x^2+y^2) with error less 
//  * 	than 1 ulps (units in the last place) 
//  */
//
// #include "fdlibm.h"
//
// #ifdef __STDC__
// 	double __ieee754_hypot(double x, double y)
// #else
// 	double __ieee754_hypot(x,y)
// 	double x, y;
// #endif
// {
// 	double a=x,b=y,t1,t2,y1,y2,w;
// 	int j,k,ha,hb;
//
// 	ha = __HI(x)&0x7fffffff;	/* high word of  x */
// 	hb = __HI(y)&0x7fffffff;	/* high word of  y */
// 	if(hb > ha) {a=y;b=x;j=ha; ha=hb;hb=j;} else {a=x;b=y;}
// 	__HI(a) = ha;	/* a <- |a| */
// 	__HI(b) = hb;	/* b <- |b| */
// 	if((ha-hb)>0x3c00000) {return a+b;} /* x/y > 2**60 */
// 	k=0;
// 	if(ha > 0x5f300000) {	/* a>2**500 */
// 	   if(ha >= 0x7ff00000) {	/* Inf or NaN */
// 	       w = a+b;			/* for sNaN */
// 	       if(((ha&0xfffff)|__LO(a))==0) w = a;
// 	       if(((hb^0x7ff00000)|__LO(b))==0) w = b;
// 	       return w;
// 	   }
// 	   /* scale a and b by 2**-600 */
// 	   ha -= 0x25800000; hb -= 0x25800000;	k += 600;
// 	   __HI(a) = ha;
// 	   __HI(b) = hb;
// 	}
// 	if(hb < 0x20b00000) {	/* b < 2**-500 */
// 	    if(hb <= 0x000fffff) {	/* subnormal b or 0 */	
// 		if((hb|(__LO(b)))==0) return a;
// 		t1=0;
// 		__HI(t1) = 0x7fd00000;	/* t1=2^1022 */
// 		b *= t1;
// 		a *= t1;
// 		k -= 1022;
// 	    } else {		/* scale a and b by 2^600 */
// 	        ha += 0x25800000; 	/* a *= 2^600 */
// 		hb += 0x25800000;	/* b *= 2^600 */
// 		k -= 600;
// 	   	__HI(a) = ha;
// 	   	__HI(b) = hb;
// 	    }
// 	}
//     /* medium size a and b */
// 	w = a-b;
// 	if (w>b) {
// 	    t1 = 0;
// 	    __HI(t1) = ha;
// 	    t2 = a-t1;
// 	    w  = sqrt(t1*t1-(b*(-b)-t2*(a+t1)));
// 	} else {
// 	    a  = a+a;
// 	    y1 = 0;
// 	    __HI(y1) = hb;
// 	    y2 = b - y1;
// 	    t1 = 0;
// 	    __HI(t1) = ha+0x00100000;
// 	    t2 = a - t1;
// 	    w  = sqrt(t1*y1-(w*(-w)-(t1*y2+t2*b)));
// 	}
// 	if(k!=0) {
// 	    t1 = 1.0;
// 	    __HI(t1) += (k<<20);
// 	    return t1*w;
// 	} else return w;
// }

///| Returns the square root of the sum of the squares of its arguments, hypot(x, y) = sqrt(x*x, y*y)
/// # Introduction
///
/// hypot return the square root of the sum of the squares of its arguments, the formula is:
///
/// $$hypot(x) = \sqrt{x^2 + y^2}$$
///
/// # Special cases
///
/// 1. If x or y is NaN, return NaN
/// 2. If x or y is inf, return +inf
///
/// # Accuracy
///
/// 2 ulps (units in the last place)
pub fn hypot(x: Double, y: Double) -> Double {
  let x = fabs(x)
  let y = fabs(y)

  if isinf(x) || isinf(y) {
    return double_pos_inf
  }

  let (x, y) = if y > x { (y, x) } else { (x, y) }

  if x * double_epsilon >= y {
    return x
  }

  let rat = y / x
  x * sqrt(1.0 + rat * rat)
}

test "hypot" {
  fn assert_hypot_ulp!(input1, input2, expect) {
    assert_ulp!(expect, hypot(input1, input2), HYPOT_MAX_ULP);
  }
  assert_hypot_ulp!(0, 0, 0);
  assert_hypot_ulp!(0, -0, 0);
  assert_hypot_ulp!(0, 1, 1);
  assert_hypot_ulp!(0, -1, 1);
  assert_hypot_ulp!(0, 2, 2);
  assert_hypot_ulp!(0, -2, 2);
  assert_hypot_ulp!(0, 3.14159, 3.14159);
  assert_hypot_ulp!(0, -3.14159, 3.14159);
  assert_hypot_ulp!(0, -2.71828, 2.71828);
  assert_hypot_ulp!(0, 2.71828, 2.71828);
  assert_hypot_ulp!(0, 1000, 1000);
  assert_hypot_ulp!(0, -1000, 1000);
  assert_hypot_ulp!(0, 0.5, 0.5);
  assert_hypot_ulp!(0, -0.5, 0.5);
  assert_hypot_ulp!(0, 0.00005, 0.00005);
  assert_hypot_ulp!(0, -0.00005, 0.00005);
  assert_hypot_ulp!(0, 0.0027818, 0.0027818);
  assert_hypot_ulp!(0, -0.0027818, 0.0027818);
  assert_hypot_ulp!(0, double_nan, double_nan);
  assert_hypot_ulp!(-0, 0, 0);
  assert_hypot_ulp!(-0, -0, 0);
  assert_hypot_ulp!(-0, 1, 1);
  assert_hypot_ulp!(-0, -1, 1);
  assert_hypot_ulp!(-0, 2, 2);
  assert_hypot_ulp!(-0, -2, 2);
  assert_hypot_ulp!(-0, 3.14159, 3.14159);
  assert_hypot_ulp!(-0, -3.14159, 3.14159);
  assert_hypot_ulp!(-0, -2.71828, 2.71828);
  assert_hypot_ulp!(-0, 2.71828, 2.71828);
  assert_hypot_ulp!(-0, 1000, 1000);
  assert_hypot_ulp!(-0, -1000, 1000);
  assert_hypot_ulp!(-0, 0.5, 0.5);
  assert_hypot_ulp!(-0, -0.5, 0.5);
  assert_hypot_ulp!(-0, 0.00005, 0.00005);
  assert_hypot_ulp!(-0, -0.00005, 0.00005);
  assert_hypot_ulp!(-0, 0.0027818, 0.0027818);
  assert_hypot_ulp!(-0, -0.0027818, 0.0027818);
  assert_hypot_ulp!(-0, double_nan, double_nan);
  assert_hypot_ulp!(1, 0, 1);
  assert_hypot_ulp!(1, -0, 1);
  assert_hypot_ulp!(1, 1, 1.414213562373095);
  assert_hypot_ulp!(1, -1, 1.414213562373095);
  assert_hypot_ulp!(1, 2, 2.23606797749979);
  assert_hypot_ulp!(1, -2, 2.23606797749979);
  assert_hypot_ulp!(1, 3.14159, 3.296905780895171);
  assert_hypot_ulp!(1, -3.14159, 3.296905780895171);
  assert_hypot_ulp!(1, -2.71828, 2.896385015566818);
  assert_hypot_ulp!(1, 2.71828, 2.896385015566818);
  assert_hypot_ulp!(1, 1000, 1000.000499999875);
  assert_hypot_ulp!(1, -1000, 1000.000499999875);
  assert_hypot_ulp!(1, 0.5, 1.118033988749895);
  assert_hypot_ulp!(1, -0.5, 1.118033988749895);
  assert_hypot_ulp!(1, 0.00005, 1.00000000125);
  assert_hypot_ulp!(1, -0.00005, 1.00000000125);
  assert_hypot_ulp!(1, 0.0027818, 1.000003869198135);
  assert_hypot_ulp!(1, -0.0027818, 1.000003869198135);
  assert_hypot_ulp!(1, double_nan, double_nan);
  assert_hypot_ulp!(-1, 0, 1);
  assert_hypot_ulp!(-1, -0, 1);
  assert_hypot_ulp!(-1, 1, 1.414213562373095);
  assert_hypot_ulp!(-1, -1, 1.414213562373095);
  assert_hypot_ulp!(-1, 2, 2.23606797749979);
  assert_hypot_ulp!(-1, -2, 2.23606797749979);
  assert_hypot_ulp!(-1, 3.14159, 3.296905780895171);
  assert_hypot_ulp!(-1, -3.14159, 3.296905780895171);
  assert_hypot_ulp!(-1, -2.71828, 2.896385015566818);
  assert_hypot_ulp!(-1, 2.71828, 2.896385015566818);
  assert_hypot_ulp!(-1, 1000, 1000.000499999875);
  assert_hypot_ulp!(-1, -1000, 1000.000499999875);
  assert_hypot_ulp!(-1, 0.5, 1.118033988749895);
  assert_hypot_ulp!(-1, -0.5, 1.118033988749895);
  assert_hypot_ulp!(-1, 0.00005, 1.00000000125);
  assert_hypot_ulp!(-1, -0.00005, 1.00000000125);
  assert_hypot_ulp!(-1, 0.0027818, 1.000003869198135);
  assert_hypot_ulp!(-1, -0.0027818, 1.000003869198135);
  assert_hypot_ulp!(-1, double_nan, double_nan);
  assert_hypot_ulp!(2, 0, 2);
  assert_hypot_ulp!(2, -0, 2);
  assert_hypot_ulp!(2, 1, 2.23606797749979);
  assert_hypot_ulp!(2, -1, 2.23606797749979);
  assert_hypot_ulp!(2, 2, 2.82842712474619);
  assert_hypot_ulp!(2, -2, 2.82842712474619);
  assert_hypot_ulp!(2, 3.14159, 3.724189539765665);
  assert_hypot_ulp!(2, -3.14159, 3.724189539765665);
  assert_hypot_ulp!(2, -2.71828, 3.37476608943494);
  assert_hypot_ulp!(2, 2.71828, 3.37476608943494);
  assert_hypot_ulp!(2, 1000, 1000.001999998);
  assert_hypot_ulp!(2, -1000, 1000.001999998);
  assert_hypot_ulp!(2, 0.5, 2.06155281280883);
  assert_hypot_ulp!(2, -0.5, 2.06155281280883);
  assert_hypot_ulp!(2, 0.00005, 2.000000000625);
  assert_hypot_ulp!(2, -0.00005, 2.000000000625);
  assert_hypot_ulp!(2, 0.0027818, 2.000001934601874);
  assert_hypot_ulp!(2, -0.0027818, 2.000001934601874);
  assert_hypot_ulp!(2, double_nan, double_nan);
  assert_hypot_ulp!(-2, 0, 2);
  assert_hypot_ulp!(-2, -0, 2);
  assert_hypot_ulp!(-2, 1, 2.23606797749979);
  assert_hypot_ulp!(-2, -1, 2.23606797749979);
  assert_hypot_ulp!(-2, 2, 2.82842712474619);
  assert_hypot_ulp!(-2, -2, 2.82842712474619);
  assert_hypot_ulp!(-2, 3.14159, 3.724189539765665);
  assert_hypot_ulp!(-2, -3.14159, 3.724189539765665);
  assert_hypot_ulp!(-2, -2.71828, 3.37476608943494);
  assert_hypot_ulp!(-2, 2.71828, 3.37476608943494);
  assert_hypot_ulp!(-2, 1000, 1000.001999998);
  assert_hypot_ulp!(-2, -1000, 1000.001999998);
  assert_hypot_ulp!(-2, 0.5, 2.06155281280883);
  assert_hypot_ulp!(-2, -0.5, 2.06155281280883);
  assert_hypot_ulp!(-2, 0.00005, 2.000000000625);
  assert_hypot_ulp!(-2, -0.00005, 2.000000000625);
  assert_hypot_ulp!(-2, 0.0027818, 2.000001934601874);
  assert_hypot_ulp!(-2, -0.0027818, 2.000001934601874);
  assert_hypot_ulp!(-2, double_nan, double_nan);
  assert_hypot_ulp!(3.14159, 0, 3.14159);
  assert_hypot_ulp!(3.14159, -0, 3.14159);
  assert_hypot_ulp!(3.14159, 1, 3.296905780895171);
  assert_hypot_ulp!(3.14159, -1, 3.296905780895171);
  assert_hypot_ulp!(3.14159, 2, 3.724189539765665);
  assert_hypot_ulp!(3.14159, -2, 3.724189539765665);
  assert_hypot_ulp!(3.14159, 3.14159, 4.442879185415692);
  assert_hypot_ulp!(3.14159, -3.14159, 4.442879185415692);
  assert_hypot_ulp!(3.14159, -2.71828, 4.154351199224736);
  assert_hypot_ulp!(3.14159, 2.71828, 4.154351199224736);
  assert_hypot_ulp!(3.14159, 1000, 1000.004934781688);
  assert_hypot_ulp!(3.14159, -1000, 1000.004934781688);
  assert_hypot_ulp!(3.14159, 0.5, 3.181129945176713);
  assert_hypot_ulp!(3.14159, -0.5, 3.181129945176713);
  assert_hypot_ulp!(3.14159, 0.00005, 3.141590000397887);
  assert_hypot_ulp!(3.14159, -0.00005, 3.141590000397887);
  assert_hypot_ulp!(3.14159, 0.0027818, 3.1415912316072);
  assert_hypot_ulp!(3.14159, -0.0027818, 3.1415912316072);
  assert_hypot_ulp!(3.14159, double_nan, double_nan);
  assert_hypot_ulp!(-3.14159, 0, 3.14159);
  assert_hypot_ulp!(-3.14159, -0, 3.14159);
  assert_hypot_ulp!(-3.14159, 1, 3.296905780895171);
  assert_hypot_ulp!(-3.14159, -1, 3.296905780895171);
  assert_hypot_ulp!(-3.14159, 2, 3.724189539765665);
  assert_hypot_ulp!(-3.14159, -2, 3.724189539765665);
  assert_hypot_ulp!(-3.14159, 3.14159, 4.442879185415692);
  assert_hypot_ulp!(-3.14159, -3.14159, 4.442879185415692);
  assert_hypot_ulp!(-3.14159, -2.71828, 4.154351199224736);
  assert_hypot_ulp!(-3.14159, 2.71828, 4.154351199224736);
  assert_hypot_ulp!(-3.14159, 1000, 1000.004934781688);
  assert_hypot_ulp!(-3.14159, -1000, 1000.004934781688);
  assert_hypot_ulp!(-3.14159, 0.5, 3.181129945176713);
  assert_hypot_ulp!(-3.14159, -0.5, 3.181129945176713);
  assert_hypot_ulp!(-3.14159, 0.00005, 3.141590000397887);
  assert_hypot_ulp!(-3.14159, -0.00005, 3.141590000397887);
  assert_hypot_ulp!(-3.14159, 0.0027818, 3.1415912316072);
  assert_hypot_ulp!(-3.14159, -0.0027818, 3.1415912316072);
  assert_hypot_ulp!(-3.14159, double_nan, double_nan);
  assert_hypot_ulp!(-2.71828, 0, 2.71828);
  assert_hypot_ulp!(-2.71828, -0, 2.71828);
  assert_hypot_ulp!(-2.71828, 1, 2.896385015566818);
  assert_hypot_ulp!(-2.71828, -1, 2.896385015566818);
  assert_hypot_ulp!(-2.71828, 2, 3.37476608943494);
  assert_hypot_ulp!(-2.71828, -2, 3.37476608943494);
  assert_hypot_ulp!(-2.71828, 3.14159, 4.154351199224736);
  assert_hypot_ulp!(-2.71828, -3.14159, 4.154351199224736);
  assert_hypot_ulp!(-2.71828, -2.71828, 3.844228442327537);
  assert_hypot_ulp!(-2.71828, 2.71828, 3.844228442327537);
  assert_hypot_ulp!(-2.71828, 1000, 1000.003694516254);
  assert_hypot_ulp!(-2.71828, -1000, 1000.003694516254);
  assert_hypot_ulp!(-2.71828, 0.5, 2.76388244294145);
  assert_hypot_ulp!(-2.71828, -0.5, 2.76388244294145);
  assert_hypot_ulp!(-2.71828, 0.00005, 2.71828000045985);
  assert_hypot_ulp!(-2.71828, -0.00005, 2.71828000045985);
  assert_hypot_ulp!(-2.71828, 0.0027818, 2.718281423401787);
  assert_hypot_ulp!(-2.71828, -0.0027818, 2.718281423401787);
  assert_hypot_ulp!(-2.71828, double_nan, double_nan);
  assert_hypot_ulp!(2.71828, 0, 2.71828);
  assert_hypot_ulp!(2.71828, -0, 2.71828);
  assert_hypot_ulp!(2.71828, 1, 2.896385015566818);
  assert_hypot_ulp!(2.71828, -1, 2.896385015566818);
  assert_hypot_ulp!(2.71828, 2, 3.37476608943494);
  assert_hypot_ulp!(2.71828, -2, 3.37476608943494);
  assert_hypot_ulp!(2.71828, 3.14159, 4.154351199224736);
  assert_hypot_ulp!(2.71828, -3.14159, 4.154351199224736);
  assert_hypot_ulp!(2.71828, -2.71828, 3.844228442327537);
  assert_hypot_ulp!(2.71828, 2.71828, 3.844228442327537);
  assert_hypot_ulp!(2.71828, 1000, 1000.003694516254);
  assert_hypot_ulp!(2.71828, -1000, 1000.003694516254);
  assert_hypot_ulp!(2.71828, 0.5, 2.76388244294145);
  assert_hypot_ulp!(2.71828, -0.5, 2.76388244294145);
  assert_hypot_ulp!(2.71828, 0.00005, 2.71828000045985);
  assert_hypot_ulp!(2.71828, -0.00005, 2.71828000045985);
  assert_hypot_ulp!(2.71828, 0.0027818, 2.718281423401787);
  assert_hypot_ulp!(2.71828, -0.0027818, 2.718281423401787);
  assert_hypot_ulp!(2.71828, double_nan, double_nan);
  assert_hypot_ulp!(1000, 0, 1000);
  assert_hypot_ulp!(1000, -0, 1000);
  assert_hypot_ulp!(1000, 1, 1000.000499999875);
  assert_hypot_ulp!(1000, -1, 1000.000499999875);
  assert_hypot_ulp!(1000, 2, 1000.001999998);
  assert_hypot_ulp!(1000, -2, 1000.001999998);
  assert_hypot_ulp!(1000, 3.14159, 1000.004934781688);
  assert_hypot_ulp!(1000, -3.14159, 1000.004934781688);
  assert_hypot_ulp!(1000, -2.71828, 1000.003694516254);
  assert_hypot_ulp!(1000, 2.71828, 1000.003694516254);
  assert_hypot_ulp!(1000, 1000, 1414.213562373095);
  assert_hypot_ulp!(1000, -1000, 1414.213562373095);
  assert_hypot_ulp!(1000, 0.5, 1000.000124999992);
  assert_hypot_ulp!(1000, -0.5, 1000.000124999992);
  assert_hypot_ulp!(1000, 0.00005, 1000.000000000001);
  assert_hypot_ulp!(1000, -0.00005, 1000.000000000001);
  assert_hypot_ulp!(1000, 0.0027818, 1000.000000003869);
  assert_hypot_ulp!(1000, -0.0027818, 1000.000000003869);
  assert_hypot_ulp!(1000, double_nan, double_nan);
  assert_hypot_ulp!(-1000, 0, 1000);
  assert_hypot_ulp!(-1000, -0, 1000);
  assert_hypot_ulp!(-1000, 1, 1000.000499999875);
  assert_hypot_ulp!(-1000, -1, 1000.000499999875);
  assert_hypot_ulp!(-1000, 2, 1000.001999998);
  assert_hypot_ulp!(-1000, -2, 1000.001999998);
  assert_hypot_ulp!(-1000, 3.14159, 1000.004934781688);
  assert_hypot_ulp!(-1000, -3.14159, 1000.004934781688);
  assert_hypot_ulp!(-1000, -2.71828, 1000.003694516254);
  assert_hypot_ulp!(-1000, 2.71828, 1000.003694516254);
  assert_hypot_ulp!(-1000, 1000, 1414.213562373095);
  assert_hypot_ulp!(-1000, -1000, 1414.213562373095);
  assert_hypot_ulp!(-1000, 0.5, 1000.000124999992);
  assert_hypot_ulp!(-1000, -0.5, 1000.000124999992);
  assert_hypot_ulp!(-1000, 0.00005, 1000.000000000001);
  assert_hypot_ulp!(-1000, -0.00005, 1000.000000000001);
  assert_hypot_ulp!(-1000, 0.0027818, 1000.000000003869);
  assert_hypot_ulp!(-1000, -0.0027818, 1000.000000003869);
  assert_hypot_ulp!(-1000, double_nan, double_nan);
  assert_hypot_ulp!(0.5, 0, 0.5);
  assert_hypot_ulp!(0.5, -0, 0.5);
  assert_hypot_ulp!(0.5, 1, 1.118033988749895);
  assert_hypot_ulp!(0.5, -1, 1.118033988749895);
  assert_hypot_ulp!(0.5, 2, 2.06155281280883);
  assert_hypot_ulp!(0.5, -2, 2.06155281280883);
  assert_hypot_ulp!(0.5, 3.14159, 3.181129945176713);
  assert_hypot_ulp!(0.5, -3.14159, 3.181129945176713);
  assert_hypot_ulp!(0.5, -2.71828, 2.76388244294145);
  assert_hypot_ulp!(0.5, 2.71828, 2.76388244294145);
  assert_hypot_ulp!(0.5, 1000, 1000.000124999992);
  assert_hypot_ulp!(0.5, -1000, 1000.000124999992);
  assert_hypot_ulp!(0.5, 0.5, 0.7071067811865476);
  assert_hypot_ulp!(0.5, -0.5, 0.7071067811865476);
  assert_hypot_ulp!(0.5, 0.00005, 0.5000000025);
  assert_hypot_ulp!(0.5, -0.00005, 0.5000000025);
  assert_hypot_ulp!(0.5, 0.0027818, 0.5000077383513579);
  assert_hypot_ulp!(0.5, -0.0027818, 0.5000077383513579);
  assert_hypot_ulp!(0.5, double_nan, double_nan);
  assert_hypot_ulp!(-0.5, 0, 0.5);
  assert_hypot_ulp!(-0.5, -0, 0.5);
  assert_hypot_ulp!(-0.5, 1, 1.118033988749895);
  assert_hypot_ulp!(-0.5, -1, 1.118033988749895);
  assert_hypot_ulp!(-0.5, 2, 2.06155281280883);
  assert_hypot_ulp!(-0.5, -2, 2.06155281280883);
  assert_hypot_ulp!(-0.5, 3.14159, 3.181129945176713);
  assert_hypot_ulp!(-0.5, -3.14159, 3.181129945176713);
  assert_hypot_ulp!(-0.5, -2.71828, 2.76388244294145);
  assert_hypot_ulp!(-0.5, 2.71828, 2.76388244294145);
  assert_hypot_ulp!(-0.5, 1000, 1000.000124999992);
  assert_hypot_ulp!(-0.5, -1000, 1000.000124999992);
  assert_hypot_ulp!(-0.5, 0.5, 0.7071067811865476);
  assert_hypot_ulp!(-0.5, -0.5, 0.7071067811865476);
  assert_hypot_ulp!(-0.5, 0.00005, 0.5000000025);
  assert_hypot_ulp!(-0.5, -0.00005, 0.5000000025);
  assert_hypot_ulp!(-0.5, 0.0027818, 0.5000077383513579);
  assert_hypot_ulp!(-0.5, -0.0027818, 0.5000077383513579);
  assert_hypot_ulp!(-0.5, double_nan, double_nan);
  assert_hypot_ulp!(0.00005, 0, 0.00005);
  assert_hypot_ulp!(0.00005, -0, 0.00005);
  assert_hypot_ulp!(0.00005, 1, 1.00000000125);
  assert_hypot_ulp!(0.00005, -1, 1.00000000125);
  assert_hypot_ulp!(0.00005, 2, 2.000000000625);
  assert_hypot_ulp!(0.00005, -2, 2.000000000625);
  assert_hypot_ulp!(0.00005, 3.14159, 3.141590000397887);
  assert_hypot_ulp!(0.00005, -3.14159, 3.141590000397887);
  assert_hypot_ulp!(0.00005, -2.71828, 2.71828000045985);
  assert_hypot_ulp!(0.00005, 2.71828, 2.71828000045985);
  assert_hypot_ulp!(0.00005, 1000, 1000.000000000001);
  assert_hypot_ulp!(0.00005, -1000, 1000.000000000001);
  assert_hypot_ulp!(0.00005, 0.5, 0.5000000025);
  assert_hypot_ulp!(0.00005, -0.5, 0.5000000025);
  assert_hypot_ulp!(0.00005, 0.00005, 7.071067811865475e-05);
  assert_hypot_ulp!(0.00005, -0.00005, 7.071067811865475e-05);
  assert_hypot_ulp!(0.00005, 0.0027818, 0.002782249313055896);
  assert_hypot_ulp!(0.00005, -0.0027818, 0.002782249313055896);
  assert_hypot_ulp!(0.00005, double_nan, double_nan);
  assert_hypot_ulp!(-0.00005, 0, 0.00005);
  assert_hypot_ulp!(-0.00005, -0, 0.00005);
  assert_hypot_ulp!(-0.00005, 1, 1.00000000125);
  assert_hypot_ulp!(-0.00005, -1, 1.00000000125);
  assert_hypot_ulp!(-0.00005, 2, 2.000000000625);
  assert_hypot_ulp!(-0.00005, -2, 2.000000000625);
  assert_hypot_ulp!(-0.00005, 3.14159, 3.141590000397887);
  assert_hypot_ulp!(-0.00005, -3.14159, 3.141590000397887);
  assert_hypot_ulp!(-0.00005, -2.71828, 2.71828000045985);
  assert_hypot_ulp!(-0.00005, 2.71828, 2.71828000045985);
  assert_hypot_ulp!(-0.00005, 1000, 1000.000000000001);
  assert_hypot_ulp!(-0.00005, -1000, 1000.000000000001);
  assert_hypot_ulp!(-0.00005, 0.5, 0.5000000025);
  assert_hypot_ulp!(-0.00005, -0.5, 0.5000000025);
  assert_hypot_ulp!(-0.00005, 0.00005, 7.071067811865475e-05);
  assert_hypot_ulp!(-0.00005, -0.00005, 7.071067811865475e-05);
  assert_hypot_ulp!(-0.00005, 0.0027818, 0.002782249313055896);
  assert_hypot_ulp!(-0.00005, -0.0027818, 0.002782249313055896);
  assert_hypot_ulp!(-0.00005, double_nan, double_nan);
  assert_hypot_ulp!(0.0027818, 0, 0.0027818);
  assert_hypot_ulp!(0.0027818, -0, 0.0027818);
  assert_hypot_ulp!(0.0027818, 1, 1.000003869198135);
  assert_hypot_ulp!(0.0027818, -1, 1.000003869198135);
  assert_hypot_ulp!(0.0027818, 2, 2.000001934601874);
  assert_hypot_ulp!(0.0027818, -2, 2.000001934601874);
  assert_hypot_ulp!(0.0027818, 3.14159, 3.1415912316072);
  assert_hypot_ulp!(0.0027818, -3.14159, 3.1415912316072);
  assert_hypot_ulp!(0.0027818, -2.71828, 2.718281423401787);
  assert_hypot_ulp!(0.0027818, 2.71828, 2.718281423401787);
  assert_hypot_ulp!(0.0027818, 1000, 1000.000000003869);
  assert_hypot_ulp!(0.0027818, -1000, 1000.000000003869);
  assert_hypot_ulp!(0.0027818, 0.5, 0.5000077383513579);
  assert_hypot_ulp!(0.0027818, -0.5, 0.5000077383513579);
  assert_hypot_ulp!(0.0027818, 0.00005, 0.002782249313055896);
  assert_hypot_ulp!(0.0027818, -0.00005, 0.002782249313055896);
  assert_hypot_ulp!(0.0027818, 0.0027818, 0.003934059287809476);
  assert_hypot_ulp!(0.0027818, -0.0027818, 0.003934059287809476);
  assert_hypot_ulp!(0.0027818, double_nan, double_nan);
  assert_hypot_ulp!(-0.0027818, 0, 0.0027818);
  assert_hypot_ulp!(-0.0027818, -0, 0.0027818);
  assert_hypot_ulp!(-0.0027818, 1, 1.000003869198135);
  assert_hypot_ulp!(-0.0027818, -1, 1.000003869198135);
  assert_hypot_ulp!(-0.0027818, 2, 2.000001934601874);
  assert_hypot_ulp!(-0.0027818, -2, 2.000001934601874);
  assert_hypot_ulp!(-0.0027818, 3.14159, 3.1415912316072);
  assert_hypot_ulp!(-0.0027818, -3.14159, 3.1415912316072);
  assert_hypot_ulp!(-0.0027818, -2.71828, 2.718281423401787);
  assert_hypot_ulp!(-0.0027818, 2.71828, 2.718281423401787);
  assert_hypot_ulp!(-0.0027818, 1000, 1000.000000003869);
  assert_hypot_ulp!(-0.0027818, -1000, 1000.000000003869);
  assert_hypot_ulp!(-0.0027818, 0.5, 0.5000077383513579);
  assert_hypot_ulp!(-0.0027818, -0.5, 0.5000077383513579);
  assert_hypot_ulp!(-0.0027818, 0.00005, 0.002782249313055896);
  assert_hypot_ulp!(-0.0027818, -0.00005, 0.002782249313055896);
  assert_hypot_ulp!(-0.0027818, 0.0027818, 0.003934059287809476);
  assert_hypot_ulp!(-0.0027818, -0.0027818, 0.003934059287809476);
  assert_hypot_ulp!(-0.0027818, double_nan, double_nan);
  assert_hypot_ulp!(double_nan, 0, double_nan);
  assert_hypot_ulp!(double_nan, -0, double_nan);
  assert_hypot_ulp!(double_nan, 1, double_nan);
  assert_hypot_ulp!(double_nan, -1, double_nan);
  assert_hypot_ulp!(double_nan, 2, double_nan);
  assert_hypot_ulp!(double_nan, -2, double_nan);
  assert_hypot_ulp!(double_nan, 3.14159, double_nan);
  assert_hypot_ulp!(double_nan, -3.14159, double_nan);
  assert_hypot_ulp!(double_nan, -2.71828, double_nan);
  assert_hypot_ulp!(double_nan, 2.71828, double_nan);
  assert_hypot_ulp!(double_nan, 1000, double_nan);
  assert_hypot_ulp!(double_nan, -1000, double_nan);
  assert_hypot_ulp!(double_nan, 0.5, double_nan);
  assert_hypot_ulp!(double_nan, -0.5, double_nan);
  assert_hypot_ulp!(double_nan, 0.00005, double_nan);
  assert_hypot_ulp!(double_nan, -0.00005, double_nan);
  assert_hypot_ulp!(double_nan, 0.0027818, double_nan);
  assert_hypot_ulp!(double_nan, -0.0027818, double_nan);
  assert_hypot_ulp!(double_nan, double_nan, double_nan);
  assert_hypot_ulp!(double_pos_inf, 0, double_pos_inf);
  assert_hypot_ulp!(3, double_neg_inf, double_pos_inf);
}

