/**
  Copyright © 2017 Odzhan. All Rights Reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are
  met:

  1. Redistributions of source code must retain the above copyright
  notice, this list of conditions and the following disclaimer.

  2. Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution.

  3. The name of the author may not be used to endorse or promote products
  derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY AUTHORS "AS IS" AND ANY EXPRESS OR
  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
  ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
  POSSIBILITY OF SUCH DAMAGE. */

#include "sha3.h"

// round constant function
// Primitive polynomial over GF(2): x^8+x^6+x^5+x^4+1
uint16_t rc (uint8_t *LFSR)
{
  uint64_t c;
  uint32_t i, t;

  c = 0;
  t = *LFSR;
  
  for (i=1; i<128; i += i) 
  {
    if (t & 1) {
      c ^= (uint64_t)1ULL << (i - 1);
    }
    t = (t & 0x80) ? (t << 1) ^ 0x71 : t << 1;
  }
  *LFSR = (uint8_t)t;
  return c;
}

void permute (uint16_t *st)
{
  int     i, j, rnd, r;
  uint16_t t, bc[5];
  uint8_t  lfsr=1;
  
const uint8_t keccakf_piln[24] = 
{ 10, 7,  11, 17, 18, 3, 5,  16, 8,  21, 24, 4, 
  15, 23, 19, 13, 12, 2, 20, 14, 22, 9,  6,  1  };
  
  for (rnd=0; rnd<20; rnd++) 
  {
    // Theta
    for (i=0; i<5; i++) {     
      bc[i] = st[i] 
            ^ st[i +  5] 
            ^ st[i + 10] 
            ^ st[i + 15] 
            ^ st[i + 20];
    }
    for (i=0; i<5; i++) {
      t = bc[(i + 4) % 5] ^ ROTL16(bc[(i + 1) % 5], 1);
      for (j=0; j<25; j+=5) {
        st[j + i] ^= t;
      }
    }
    // Rho Pi
    t = st[1];
    for (i=0, r=0; i<24; i++) {
      r += i + 1;
      j = keccakf_piln[i];
      bc[0] = st[j];
      st[j] = ROTL16(t, r & 15);
      t = bc[0];
    }
    // Chi
    for (j=0; j<25; j+=5) {
      for (i=0; i<5; i++) {
        bc[i] = st[j + i];
      }
      for (i=0; i<5; i++) {
        st[j + i] ^= (~bc[(i + 1) % 5]) & bc[(i + 2) % 5];
      }
    }
    // Iota
    st[0] ^= rc(&lfsr);
  }
}

#ifdef TEST

uint8_t tv1[]={
  0x5d,0xd4,0x31,0xe5,0xfb,0xc6,0x04,0xf4,
  0x99,0xbf,0xa0,0x23,0x2f,0x45,0xf8,0xf1,
  0x42,0xd0,0xff,0x51,0x78,0xf5,0x39,0xe5,
  0xa7,0x80,0x0b,0xf0,0x64,0x36,0x97,0xaf,
  0x4c,0xf3,0x5a,0xbf,0x24,0x24,0x7a,0x22,
  0x15,0x27,0x17,0x88,0x84,0x58,0x68,0x9f,
  0x54,0xd0,0x5c,0xb1,0x0e,0xfc,0xf4,0x1b,
  0x91,0xfa,0x66,0x61,0x9a,0x59,0x9e,0x1a,
  0x1f,0x0a,0x97,0xa3,0x87,0x96,0x65,0xab,
  0x68,0x8d,0xab,0xaf,0x15,0x10,0x4b,0xe7,
  0x98,0x1a,0x00,0x34,0xf3,0xef,0x19,0x41,
  0x76,0x0e,0x0a,0x93,0x70,0x80,0xb2,0x87,
  0x96,0xe9,0xef,0x11 };

uint8_t tv2[]={
  0x0d,0x2d,0xbf,0x75,0x89,0x0e,0x61,0x9b,
  0x40,0xaf,0x26,0xc8,0xab,0x84,0xcd,0x64,
  0xd6,0xbd,0x05,0xf9,0x35,0x28,0x83,0xbc,
  0xb9,0x01,0x80,0x5f,0xce,0x2c,0x66,0x15,
  0x5e,0xc9,0x38,0x8e,0x43,0xe5,0x1f,0x70,
  0x80,0x43,0x54,0x1b,0xff,0xde,0xac,0x89,
  0xde,0xb5,0xed,0x51,0xd9,0x02,0x97,0x0e,
  0x16,0xaa,0x19,0x6c,0xee,0x3e,0x91,0xa2,
  0x9a,0x4e,0x75,0x60,0x3c,0x06,0x19,0x98,
  0x54,0x92,0x70,0xf4,0x84,0x90,0x9f,0xd0,
  0x59,0xa2,0x2d,0x77,0xf7,0x5d,0xb3,0x1d,
  0x62,0x01,0xa6,0x5a,0xd5,0x25,0x88,0x35,
  0xab,0x3b,0x78,0xb3 };
  
int main(int argc, char *argv[])
{
  uint8_t  out[50];
  int      i;
  
  memset(out, 0, sizeof(out));
  
  permute((uint16_t*)out);
  
  for (i=0; i<50; i++) {
    printf("%02x", out[i]);
  }
  putchar('\n');

  return 0;
}
#endif