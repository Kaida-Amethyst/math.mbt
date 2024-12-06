// #ifdef __STDC__
// 	double erfc(double x) 
// #else
// 	double erfc(x) 
// 	double x;
// #endif
// {
// 	int hx,ix;
// 	double R,S,P,Q,s,y,z,r;
// 	hx = __HI(x);
// 	ix = hx&0x7fffffff;
// 	if(ix>=0x7ff00000) {			/* erfc(nan)=nan */
// 						/* erfc(+-inf)=0,2 */
// 	    return (double)(((unsigned)hx>>31)<<1)+one/x;
// 	}
//
// 	if(ix < 0x3feb0000) {		/* |x|<0.84375 */
// 	    if(ix < 0x3c700000)  	/* |x|<2**-56 */
// 		return one-x;
// 	    z = x*x;
// 	    r = pp0+z*(pp1+z*(pp2+z*(pp3+z*pp4)));
// 	    s = one+z*(qq1+z*(qq2+z*(qq3+z*(qq4+z*qq5))));
// 	    y = r/s;
// 	    if(hx < 0x3fd00000) {  	/* x<1/4 */
// 		return one-(x+x*y);
// 	    } else {
// 		r = x*y;
// 		r += (x-half);
// 	        return half - r ;
// 	    }
// 	}
// 	if(ix < 0x3ff40000) {		/* 0.84375 <= |x| < 1.25 */
// 	    s = fabs(x)-one;
// 	    P = pa0+s*(pa1+s*(pa2+s*(pa3+s*(pa4+s*(pa5+s*pa6)))));
// 	    Q = one+s*(qa1+s*(qa2+s*(qa3+s*(qa4+s*(qa5+s*qa6)))));
// 	    if(hx>=0) {
// 	        z  = one-erx; return z - P/Q; 
// 	    } else {
// 		z = erx+P/Q; return one+z;
// 	    }
// 	}
// 	if (ix < 0x403c0000) {		/* |x|<28 */
// 	    x = fabs(x);
//  	    s = one/(x*x);
// 	    if(ix< 0x4006DB6D) {	/* |x| < 1/.35 ~ 2.857143*/
// 	        R=ra0+s*(ra1+s*(ra2+s*(ra3+s*(ra4+s*(
// 				ra5+s*(ra6+s*ra7))))));
// 	        S=one+s*(sa1+s*(sa2+s*(sa3+s*(sa4+s*(
// 				sa5+s*(sa6+s*(sa7+s*sa8)))))));
// 	    } else {			/* |x| >= 1/.35 ~ 2.857143 */
// 		if(hx<0&&ix>=0x40180000) return two-tiny;/* x < -6 */
// 	        R=rb0+s*(rb1+s*(rb2+s*(rb3+s*(rb4+s*(
// 				rb5+s*rb6)))));
// 	        S=one+s*(sb1+s*(sb2+s*(sb3+s*(sb4+s*(
// 				sb5+s*(sb6+s*sb7))))));
// 	    }
// 	    z  = x;
// 	    __LO(z)  = 0;
// 	    r  =  __ieee754_exp(-z*z-0.5625)*
// 			__ieee754_exp((z-x)*(z+x)+R/S);
// 	    if(hx>0) return r/x; else return two-r/x;
// 	} else {
// 	    if(hx>0) return tiny*tiny; else return two-tiny;
// 	}
// }

