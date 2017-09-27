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

#include "keccak.h"

/**
// round constant function
// Primitive polynomial over GF(2): x^8+x^6+x^5+x^4+1
uint32_t rc (uint8_t *LFSR)
{
  uint32_t c; 
  int8_t   t;
  uint8_t  i;

  c = 0;
  t = *LFSR;
  
  for (i=1; i<128; i += i) 
  {
    if (t & 1) {
      // if shift value is < 32
      if ((i-1) < 32) {
        c ^= 1UL << (i - 1);
      }
    }
    t = (t & 0x80) ? (t << 1) ^ 0x71 : t << 1;
  }
  *LFSR = (uint8_t)t;
  return c;
}*/

__declspec(naked) uint32_t rcx (uint8_t *LFSR)
{
  __asm {
    int 3
    xor    eax, eax    
rc_lx:
        
    pushad
    xor    eax, eax            ; eax = 0
    cdq
    xchg   eax, ebx            ; c = 0
    inc    edx                 ; i = 1    
    mov    edi, [esp+32+4]     ; edi = &LFSR
    movzx  eax, byte[edi]      ; al = t = *LFSR
rc_l0:    
    test   al, 1               ; t & 1
    je     rc_l1    
    lea    ecx, [edx-1]        ; ecx = (i - 1)
    cmp    cl, 32              ; skip if (ecx >= 32)
    jae    rc_l1    
    btc    ebx, ecx            ; c ^= 1UL << (i - 1)
rc_l1:    
    add    al, al              ; t << 1
    sbb    ah, ah              ; ah = (t < 0) ? 0x00 : 0xFF
    and    ah, 0x71            ; ah = (ah == 0xFF) ? 0x71 : 0x00  
    xor    al, ah  
    add    dl, dl              ; i += i
    jns    rc_l0               ; while (i != 128)
    stosb                      ; save t
    mov    [esp+28], ebx       ; return c & 255
    popad
    ret
  };
}

__declspec(naked) uint32_t k800_permutex (void *state) {
  __asm {
    pushad
    call   ld_var
    // pi
    dd     0x110b070a, 0x10050312, 0x04181508 
    dd     0x0d13170f, 0x0e14020c, 0x01060916
    // modulo 5    
    dd     0x03020100, 0x02010004, 0x00000403
ld_var:
    pop    eax
    pushad                       ; create local space
    mov    edi, esp
    stosd
    push   22
    pop    ecx
k_l0:    
    push   ecx
    mov    cl, 5
    pushad
k_l1:
    ; Theta
    lodsd
    xor    eax, [esi+ 5*4-4]
    xor    eax, [esi+10*4-4]
    xor    eax, [esi+15*4-4]
    xor    eax, [esi+20*4-4]
    stosd
    loop   k_l1
    popad 
    xor    eax, eax
k_l2:
    movzx  edx, [ebx+eax+1]     ; edx = m[(i + 1)]
    movzx  ebp, [ebx+eax+4]     ; ebp = m[(i + 4)]
    
    mov    edx, [esi+edx*4]     ; edx = bc[(i+1)%5]
    mov    ebp, [esi+ebp*4]     ; ebp = bc[(i+4)%5]
    
    rol    edx, 1
    xor    ebp, edx
k_l3:
    lea    ebp, [eax+edx]    
    xor    [edi+eax*4], ebp
    inc    edx
    cmp    dl, cl
    jnz    k_l3
    loop   k_l2
    ; Rho Pi
    
    ; Chi
    
    ; Iota
    call   rcx
    xor    [edi], eax
    
    pop    ecx
    loop   k_l0
    
    popad
  };
}

void k800_permute (void *state)
{
  uint32_t i, j, rnd, r;
  uint32_t t, bc[5];
  uint8_t  lfsr=1;
  uint32_t *st=(uint32_t*)state;
  uint8_t  *p, *m;
  
  uint32_t piln[6]=
  { 0x110b070a, 0x10050312, 0x04181508, 
    0x0d13170f, 0x0e14020c, 0x01060916 };

  uint32_t m5[3]=
  { 0x03020100, 0x02010004, 0x00000403 };
  
  p = (uint8_t*)piln;
  m = (uint8_t*)m5;
  
  for (rnd=0; rnd<22; rnd++) 
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
      t = bc[m[(i + 4)]] ^ ROTL32(bc[m[(i + 1)]], 1);
      for (j=0; j<25; j+=5) {
        st[j + i] ^= t;
      }
    }
    // Rho Pi
    t = st[1];
    for (i=0, r=0; i<24; i++) {
      r += i + 1;
      j = p[i];
      bc[0] = st[j];
      st[j] = ROTL32(t, r & 31);
      t = bc[0];
    }
    // Chi
    for (j=0; j<25; j+=5) {
      for (i=0; i<5; i++) {
        bc[i] = st[j + i];
      }
      for (i=0; i<5; i++) {
        st[j + i] ^= (~bc[m[(i + 1)]]) & bc[m[(i + 2)]];
      }
    }
    // Iota
    st[0] ^= rcx(&lfsr);
  }
}

#ifdef TEST

#include <stdio.h>

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
  
void bin2hex(uint8_t x[], int len) {
  int i;
  for (i=0; i<len; i++) {
    if ((i & 7)==0) putchar('\n');
    printf ("0x%02x,", x[i]);
  }
  putchar('\n');
}
  
int main(void)
{
  uint8_t  out[100];
  int      equ;
  
  memset(out, 0, sizeof(out));
  
  k800_permute(out);
  equ = memcmp(out, tv1, sizeof(tv1))==0;
  printf("Test 1 %s\n", equ ? "OK" : "Failed"); 
  //bin2hex(out, 100);

  k800_permute(out);
  equ = memcmp(out, tv2, sizeof(tv2))==0;
  printf("Test 2 %s\n", equ ? "OK" : "Failed");
  //bin2hex(out, 100);

  return 0;
}
#endif