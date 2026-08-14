// Derived from musl libc src/math/{__sindf,__cosdf,__tandf,
// __rem_pio2f,__rem_pio2_large}.c at commit
// f21a96538f78fa8e2040831b4209b35f2fb581da.
//
// The large reducer is specialized for the binary32 caller: nx is always 1
// and prec is always 0. The arithmetic, tables, and recomputation rule remain
// those of musl's __rem_pio2_large.
//
// origin: FreeBSD msun / SunPro / SunSoft
// ====================================================
// Copyright (C) 1993 by Sun Microsystems, Inc. All rights reserved.
//
// Developed at SunPro, a Sun Microsystems, Inc. business.
// Permission to use, copy, modify, and distribute this
// software is freely granted, provided that this notice
// is preserved.
// ====================================================
// Copyright (C) 1993 by Sun Microsystems, Inc. All rights reserved.
//
// Developed at SunSoft, a Sun Microsystems, Inc. business.
// Permission to use, copy, modify, and distribute this
// software is freely granted, provided that this notice
// is preserved.
// ====================================================
// Copyright 2004 Sun Microsystems, Inc.  All Rights Reserved.
//
// Permission to use, copy, modify, and distribute this
// software is freely granted, provided that this notice
// is preserved.
// ====================================================

///|
let musl_two_over_pi : ReadOnlyArray[Int] = [
  0xa2f983, 0x6e4e44, 0x1529fc, 0x2757d1, 0xf534dd, 0xc0db62, 0x95993c, 0x439041,
  0xfe5163, 0xabdebb, 0xc561b7, 0x246e3a, 0x424dd2, 0xe00649, 0x2eea09, 0xd1921c,
  0xfe1deb, 0x1cb129, 0xa73ee8, 0x8235f5, 0x2ebb44, 0x84e99c, 0x7026b4, 0x5f7e41,
  0x3991d6, 0x398353, 0x39f49c, 0x845f8b, 0xbdf928, 0x3b1ff8, 0x97ffde, 0x05980f,
  0xef2f11, 0x8b5a0a, 0x6d1f6d, 0x367ecf, 0x27cb09, 0xb74f46, 0x3f669e, 0x5fea2d,
  0x7527ba, 0xc7ebe5, 0xf17b3d, 0x0739f7, 0x8a5292, 0xea6bfb, 0x5fb11f, 0x8d5d08,
  0x560330, 0x46fc7b, 0x6babf0, 0xcfbc20, 0x9af436, 0x1da9e3, 0x91615e, 0xe61b08,
  0x659985, 0x5f14a0, 0x68408d, 0xffd880, 0x4d7327, 0x310606, 0x1556ca, 0x73a8c9,
  0x60e27b, 0xc08c6b,
]

///|
let musl_pi_over_two_chunks : ReadOnlyArray[Double] = [
  1.57079625129699707031e+00, 7.54978941586159635335e-08, 5.39030252995776476554e-15,
  3.28200341580791294123e-22,
]

///|
fn musl_sindf(input : Double) -> Float {
  // |sin(x) / x - s(x)| < 2^-37.5 on [-pi/4, pi/4].
  let s1 = -0x1.5555554cbac77p-3
  let s2 = 0x1.11110896efbb2p-7
  let s3 = -0x1.a00f9e2cae774p-13
  let s4 = 0x1.6cd878c3b46a7p-19
  let z = input * input
  let w = z * z
  let r = s3 + z * s4
  let s = z * input
  Float::from_double(input + s * (s1 + z * s2) + s * w * r)
}

///|
fn musl_cosdf(input : Double) -> Float {
  // |cos(x) - c(x)| < 2^-34.1 on [-pi/4, pi/4].
  let c0 = -0x1.ffffffd0c5e81p-2
  let c1 = 0x1.55553e1053a42p-5
  let c2 = -0x1.6c087e80f1e27p-10
  let c3 = 0x1.99342e0ee5069p-16
  let z = input * input
  let w = z * z
  let r = c2 + z * c3
  Float::from_double(1.0 + z * c0 + w * c1 + w * z * r)
}

///|
fn musl_tandf(input : Double, reciprocal_branch : Bool) -> Float {
  // |tan(x) / x - t(x)| < 2^-25.5 on [-pi/4, pi/4].
  let t0 = 0x1.5554d3418c99fp-2
  let t1 = 0x1.112fd38999f72p-3
  let t2 = 0x1.b54c91d865afep-5
  let t3 = 0x1.91df3908c33cep-6
  let t4 = 0x1.85dadfcecf44ep-9
  let t5 = 0x1.362b9bf971bcdp-7
  let z = input * input
  let r = t4 + z * t5
  let t = t2 + z * t3
  let w = z * z
  let s = z * input
  let u = t0 + z * t1
  let r = input + s * u + s * w * (t + w * r)
  Float::from_double(if reciprocal_branch { -1.0 / r } else { r })
}

///|
fn musl_rem_pio2_large_single(input : Double, e0 : Int) -> (Double, Int) {
  // This is musl __rem_pio2_large with nx=1, prec=0, jk=jp=3.
  let two24 = 0x1.0p24
  let twon24 = 0x1.0p-24
  let iq : Array[Int] = Array::make(20, 0)
  let fq : Array[Double] = Array::make(20, 0.0)
  let q : Array[Double] = Array::make(20, 0.0)
  let jk = 3
  let jp = 3
  let mut jv = (e0 - 3) / 24
  if jv < 0 {
    jv = 0
  }
  let mut q0 = e0 - 24 * (jv + 1)
  for i = 0; i <= jk; i = i + 1 {
    q[i] = input * musl_two_over_pi[jv + i].to_double()
  }
  let mut jz = jk
  let mut n = 0
  let mut ih = 0
  let mut z = 0.0
  let mut fw = 0.0
  let mut recompute = true
  while recompute {
    recompute = false
    let mut i = 0
    let mut j = jz
    z = q[jz]
    while j > 0 {
      fw = (twon24 * z).to_int().to_double()
      iq[i] = (z - two24 * fw).to_int()
      z = q[j - 1] + fw
      i += 1
      j -= 1
    }
    z = scalbn(z, q0)
    z -= 8.0 * (z * 0.125).floor()
    n = z.to_int()
    z -= n.to_double()
    ih = 0
    if q0 > 0 {
      i = iq[jz - 1] >> (24 - q0)
      n += i
      iq[jz - 1] -= i << (24 - q0)
      ih = iq[jz - 1] >> (23 - q0)
    } else if q0 == 0 {
      ih = iq[jz - 1] >> 23
    } else if z >= 0.5 {
      ih = 2
    }
    if ih > 0 {
      n += 1
      let mut carry = 0
      i = 0
      while i < jz {
        j = iq[i]
        if carry == 0 {
          if j != 0 {
            carry = 1
            iq[i] = 0x1000000 - j
          }
        } else {
          iq[i] = 0xffffff - j
        }
        i += 1
      }
      if q0 > 0 {
        match q0 {
          1 => iq[jz - 1] = iq[jz - 1] & 0x7fffff
          2 => iq[jz - 1] = iq[jz - 1] & 0x3fffff
          _ => ()
        }
      }
      if ih == 2 {
        z = 1.0 - z
        if carry != 0 {
          z -= scalbn(1.0, q0)
        }
      }
    }

    if z == 0.0 {
      j = 0
      i = jz - 1
      while i >= jk {
        j = j | iq[i]
        i -= 1
      }
      if j == 0 {
        let mut k = 1
        while iq[jk - k] == 0 {
          k += 1
        }
        i = jz + 1
        while i <= jz + k {
          q[i] = input * musl_two_over_pi[jv + i].to_double()
          i += 1
        }
        jz += k
        recompute = true
        continue
      }
    }

    if z == 0.0 {
      jz -= 1
      q0 -= 24
      while iq[jz] == 0 {
        jz -= 1
        q0 -= 24
      }
    } else {
      z = scalbn(z, -q0)
      if z >= two24 {
        fw = (twon24 * z).to_int().to_double()
        iq[jz] = (z - two24 * fw).to_int()
        jz += 1
        q0 += 24
        iq[jz] = fw.to_int()
      } else {
        iq[jz] = z.to_int()
      }
    }

    fw = scalbn(1.0, q0)
    i = jz
    while i >= 0 {
      q[i] = fw * iq[i].to_double()
      fw *= twon24
      i -= 1
    }

    i = jz
    while i >= 0 {
      fw = 0.0
      let mut k = 0
      while k <= jp && k <= jz - i {
        fw += musl_pi_over_two_chunks[k] * q[i + k]
        k += 1
      }
      fq[jz - i] = fw
      i -= 1
    }

    fw = 0.0
    i = jz
    while i >= 0 {
      fw += fq[i]
      i -= 1
    }
  }
  (if ih == 0 { fw } else { -fw }, n & 7)
}

///|
fn musl_rem_pio2f(input : Float) -> (Double, Int) {
  let bits = input.reinterpret_as_uint()
  let magnitude = bits & 0x7fffffffU
  let x = input.to_double()
  if magnitude < 0x4dc90fdbU {
    // 25+53 bits of pi are sufficient below 2^28 * (pi/2).
    let invpio2 = 6.36619772367581382433e-01
    let pio2_1 = 1.57079631090164184570e+00
    let pio2_1t = 1.58932547735281966916e-08
    let pio4 = 0x1.921fb6p-1
    let toint = 0x1.8p52
    let mut fn_ = x * invpio2 + toint - toint
    let mut n = fn_.to_int()
    let mut remainder = x - fn_ * pio2_1 - fn_ * pio2_1t
    if remainder < -pio4 {
      n -= 1
      fn_ -= 1.0
      remainder = x - fn_ * pio2_1 - fn_ * pio2_1t
    } else if remainder > pio4 {
      n += 1
      fn_ += 1.0
      remainder = x - fn_ * pio2_1 - fn_ * pio2_1t
    }
    return (remainder, n)
  }

  let sign = bits >> 31 != 0U
  let e0 = (magnitude >> 23).reinterpret_as_int() - (0x7f + 23)
  let scaled_bits = magnitude - (e0 << 23).reinterpret_as_uint()
  let scaled = Float::reinterpret_from_uint(scaled_bits).to_double()
  let (remainder, quadrant) = musl_rem_pio2_large_single(scaled, e0)
  if sign {
    (-remainder, -quadrant)
  } else {
    (remainder, quadrant)
  }
}
