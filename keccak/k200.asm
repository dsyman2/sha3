; Listing generated by Microsoft (R) Optimizing Compiler Version 16.00.40219.01 

	TITLE	c:\hub\sha3\keccak\k200.c
	.686P
	.XMM
	include listing.inc
	.model	flat

INCLUDELIB LIBCMT
INCLUDELIB OLDNAMES

PUBLIC	_k200_permute
; Function compile flags: /Ogspy
; File c:\hub\sha3\keccak\k200.c
;	COMDAT _k200_permute
_TEXT	SEGMENT
_keccakf_piln$ = -68					; size = 24
_rc$ = -44						; size = 18
_keccakf_mod5$ = -24					; size = 10
_bc$ = -12						; size = 5
_rnd$ = -4						; size = 4
tv807 = 8						; size = 4
_state$ = 8						; size = 4
_k200_permute PROC					; COMDAT

; 33   : {

	push	ebp
	mov	ebp, esp
	sub	esp, 68					; 00000044H

; 34   :   int     i, j, rnd, r;
; 35   :   uint8_t t, bc[5];
; 36   :   uint8_t *st = (uint8_t*)state;
; 37   :   
; 38   : uint8_t rc[]={
; 39   :   0x01,0x82,0x8a,0x00,0x8b,0x01,0x81,0x09,0x8a,
; 40   :   0x88,0x09,0x0a,0x8b,0x8b,0x89,0x03,0x02,0x80};
; 41   :   
; 42   : const uint8_t keccakf_piln[24] = 
; 43   : { 10, 7,  11, 17, 18, 3, 5,  16, 8,  21, 24, 4, 
; 44   :   15, 23, 19, 13, 12, 2, 20, 14, 22, 9,  6,  1  };
; 45   :   
; 46   : const uint8_t keccakf_mod5[10] = 
; 47   : { 0, 1, 2, 3, 4, 0, 1, 2, 3, 4 };
; 48   :   
; 49   :   for (rnd=0; rnd<18; rnd++) 

	mov	eax, DWORD PTR _state$[ebp]
	and	DWORD PTR _rnd$[ebp], 0
	push	ebx
	mov	DWORD PTR tv807[ebp], eax
	lea	ecx, DWORD PTR _keccakf_mod5$[ebp+4]
	sub	DWORD PTR tv807[ebp], ecx
	push	esi
	mov	DWORD PTR _rc$[ebp], 9077249		; 008a8201H
	mov	DWORD PTR _rc$[ebp+4], 159449483	; 0981018bH
	mov	DWORD PTR _rc$[ebp+8], 168396938	; 0a09888aH
	mov	DWORD PTR _rc$[ebp+12], 59345803	; 03898b8bH
	mov	WORD PTR _rc$[ebp+16], 32770		; 00008002H
	mov	DWORD PTR _keccakf_piln$[ebp], 285935370 ; 110b070aH
	mov	DWORD PTR _keccakf_piln$[ebp+4], 268763922 ; 10050312H
	mov	DWORD PTR _keccakf_piln$[ebp+8], 68687112 ; 04181508H
	mov	DWORD PTR _keccakf_piln$[ebp+12], 219354895 ; 0d13170fH
	mov	DWORD PTR _keccakf_piln$[ebp+16], 236192268 ; 0e14020cH
	mov	DWORD PTR _keccakf_piln$[ebp+20], 17172758 ; 01060916H
	mov	DWORD PTR _keccakf_mod5$[ebp], 50462976	; 03020100H
	mov	DWORD PTR _keccakf_mod5$[ebp+4], 33619972 ; 02010004H
	mov	WORD PTR _keccakf_mod5$[ebp+8], 1027	; 00000403H
	push	edi
$LL43@k200_permu:

; 50   :   {
; 51   :     // Theta
; 52   :     for (i=0; i<5; i++) {     

	push	5
	lea	esi, DWORD PTR _bc$[ebp]
	lea	ecx, DWORD PTR [eax+15]
	pop	edi
$LL21@k200_permu:

; 53   :       bc[i] = st[i] 
; 54   :             ^ st[i +  5] 
; 55   :             ^ st[i + 10] 
; 56   :             ^ st[i + 15] 
; 57   :             ^ st[i + 20];

	mov	dl, BYTE PTR [ecx-15]
	xor	dl, BYTE PTR [ecx-10]
	xor	dl, BYTE PTR [ecx-5]
	xor	dl, BYTE PTR [ecx+5]
	xor	dl, BYTE PTR [ecx]
	inc	ecx
	mov	BYTE PTR [esi], dl
	inc	esi
	dec	edi
	jne	SHORT $LL21@k200_permu

; 58   :     }
; 59   :     for (i=0; i<5; i++) {

	xor	esi, esi
$LL18@k200_permu:

; 60   :       t = bc[keccakf_mod5[(i + 4)]] ^ ROTL8(bc[keccakf_mod5[(i + 1)]], 1);

	lea	ecx, DWORD PTR _keccakf_mod5$[ebp+esi+4]
	movzx	edx, BYTE PTR [ecx-3]
	movzx	edi, BYTE PTR [ecx]
	mov	dl, BYTE PTR _bc$[ebp+edx]
	rol	dl, 1
	xor	dl, BYTE PTR _bc$[ebp+edi]
	add	ecx, DWORD PTR tv807[ebp]
	push	5
	pop	edi
$LL15@k200_permu:

; 61   :       for (j=0; j<25; j+=5) {
; 62   :         st[j + i] ^= t;

	xor	BYTE PTR [ecx], dl
	add	ecx, 5
	dec	edi
	jne	SHORT $LL15@k200_permu

; 58   :     }
; 59   :     for (i=0; i<5; i++) {

	inc	esi
	cmp	esi, 5
	jl	SHORT $LL18@k200_permu

; 63   :       }
; 64   :     }
; 65   :     // Rho Pi
; 66   :     t = st[1];

	mov	bl, BYTE PTR [eax+1]

; 67   :     for (i=0, r=0; i<24; i++) {

	xor	edx, edx
$LL44@k200_permu:

; 68   :       r += i + 1;
; 69   :       j = keccakf_piln[i];

	movzx	esi, BYTE PTR _keccakf_piln$[ebp+edi]

; 70   :       bc[0] = st[j];

	mov	cl, BYTE PTR [esi+eax]
	lea	edx, DWORD PTR [edx+edi+1]
	mov	BYTE PTR _bc$[ebp], cl

; 71   :       st[j] = ROTL8(t, r & 7);

	mov	ecx, edx
	and	ecx, 7
	rol	bl, cl
	inc	edi
	mov	BYTE PTR [esi+eax], bl

; 72   :       t = bc[0];

	mov	bl, BYTE PTR _bc$[ebp]
	cmp	edi, 24					; 00000018H
	jl	SHORT $LL44@k200_permu

; 73   :     }
; 74   :     // Chi
; 75   :     for (j=0; j<25; j+=5) {

	push	5
	mov	ecx, eax
	pop	edx
$LL9@k200_permu:

; 76   :       for (i=0; i<5; i++) {
; 77   :         bc[i] = st[j + i];

	mov	esi, ecx
	lea	edi, DWORD PTR _bc$[ebp]
	movsd
	movsb

; 78   :       }
; 79   :       for (i=0; i<5; i++) {

	xor	esi, esi
$LL3@k200_permu:

; 80   :         st[j + i] ^= (~bc[keccakf_mod5[(i + 1)]]) & bc[keccakf_mod5[(i + 2)]];

	movzx	edi, BYTE PTR _keccakf_mod5$[ebp+esi+1]
	mov	bl, BYTE PTR _bc$[ebp+edi]
	movzx	edi, BYTE PTR _keccakf_mod5$[ebp+esi+2]
	not	bl
	and	bl, BYTE PTR _bc$[ebp+edi]
	xor	BYTE PTR [ecx], bl
	inc	esi
	inc	ecx
	cmp	esi, 5
	jl	SHORT $LL3@k200_permu

; 73   :     }
; 74   :     // Chi
; 75   :     for (j=0; j<25; j+=5) {

	dec	edx
	jne	SHORT $LL9@k200_permu

; 81   :       }
; 82   :     }
; 83   :     // Iota
; 84   :     st[0] ^= rc[rnd];

	mov	ecx, DWORD PTR _rnd$[ebp]
	mov	cl, BYTE PTR _rc$[ebp+ecx]
	xor	BYTE PTR [eax], cl
	inc	DWORD PTR _rnd$[ebp]
	cmp	DWORD PTR _rnd$[ebp], 18		; 00000012H
	jl	$LL43@k200_permu
	pop	edi
	pop	esi
	pop	ebx

; 85   :   }
; 86   : }

	leave
	ret	0
_k200_permute ENDP
_TEXT	ENDS
END