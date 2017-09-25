; Listing generated by Microsoft (R) Optimizing Compiler Version 16.00.40219.01 

	TITLE	c:\hub\sha3\keccak\k800.c
	.686P
	.XMM
	include listing.inc
	.model	flat

INCLUDELIB LIBCMT
INCLUDELIB OLDNAMES

PUBLIC	_rc
; Function compile flags: /Ogspy
; File c:\hub\sha3\keccak\k800.c
;	COMDAT _rc
_TEXT	SEGMENT
_LFSR$ = 8						; size = 4
_rc	PROC						; COMDAT

; 35   : {

	push	ebx
	push	esi

; 36   :   uint32_t c; 
; 37   :   int8_t   t;
; 38   :   uint8_t  i;
; 39   : 
; 40   :   c = 0;
; 41   :   t = *LFSR;

	mov	esi, DWORD PTR _LFSR$[esp+4]
	mov	dl, BYTE PTR [esi]
	push	edi
	xor	eax, eax

; 42   :   
; 43   :   for (i=1; i<128; i += i) 

	mov	bl, 1
$LL5@rc:

; 44   :   {
; 45   :     if (t & 1) {

	test	dl, 1
	je	SHORT $LN1@rc

; 46   :       // if shift value is < 32
; 47   :       if ((i-1) < 32) {

	movzx	ecx, bl
	lea	edi, DWORD PTR [ecx-1]
	cmp	edi, 32					; 00000020H
	jge	SHORT $LN1@rc

; 48   :         c ^= 1UL << (i - 1);

	xor	edi, edi
	dec	ecx
	inc	edi
	shl	edi, cl
	xor	eax, edi
$LN1@rc:

; 49   :       }
; 50   :     }
; 51   :     t = (t & 0x80) ? (t << 1) ^ 0x71 : t << 1;

	test	dl, dl
	jns	SHORT $LN8@rc
	add	dl, dl
	xor	dl, 113					; 00000071H
	jmp	SHORT $LN9@rc
$LN8@rc:
	add	dl, dl
$LN9@rc:

; 42   :   
; 43   :   for (i=1; i<128; i += i) 

	add	bl, bl
	cmp	bl, 128					; 00000080H
	jb	SHORT $LL5@rc

; 52   :   }
; 53   :   *LFSR = (uint8_t)t;

	pop	edi
	mov	BYTE PTR [esi], dl
	pop	esi
	pop	ebx

; 54   :   return c;
; 55   : }

	ret	0
_rc	ENDP
_TEXT	ENDS
PUBLIC	_k800_permute
; Function compile flags: /Ogspy
;	COMDAT _k800_permute
_TEXT	SEGMENT
_keccakf_piln$ = -60					; size = 24
_bc$ = -36						; size = 20
_keccakf_mod5$ = -16					; size = 10
_lfsr$ = -1						; size = 1
tv1255 = 8						; size = 4
_state$ = 8						; size = 4
_k800_permute PROC					; COMDAT

; 111  : {

	push	ebp
	mov	ebp, esp
	sub	esp, 60					; 0000003cH
	push	ebx

; 112  :   uint32_t i, j, rnd, r;
; 113  :   uint32_t t, bc[5];
; 114  :   uint8_t  lfsr=1;
; 115  :   uint32_t *st=(uint32_t*)state;
; 116  :   
; 117  : const uint8_t keccakf_piln[24] = 
; 118  : { 10, 7,  11, 17, 18, 3, 5,  16, 8,  21, 24, 4, 
; 119  :   15, 23, 19, 13, 12, 2, 20, 14, 22, 9,  6,  1  };
; 120  :   
; 121  : const uint8_t keccakf_mod5[10] = 
; 122  : { 0, 1, 2, 3, 4, 0, 1, 2, 3, 4 };

	mov	ebx, DWORD PTR _state$[ebp]
	push	esi
	push	edi
	mov	BYTE PTR _lfsr$[ebp], 1
	mov	DWORD PTR _keccakf_piln$[ebp], 285935370 ; 110b070aH
	mov	DWORD PTR _keccakf_piln$[ebp+4], 268763922 ; 10050312H
	mov	DWORD PTR _keccakf_piln$[ebp+8], 68687112 ; 04181508H
	mov	DWORD PTR _keccakf_piln$[ebp+12], 219354895 ; 0d13170fH
	mov	DWORD PTR _keccakf_piln$[ebp+16], 236192268 ; 0e14020cH
	mov	DWORD PTR _keccakf_piln$[ebp+20], 17172758 ; 01060916H
	mov	DWORD PTR _keccakf_mod5$[ebp], 50462976	; 03020100H
	mov	DWORD PTR _keccakf_mod5$[ebp+4], 33619972 ; 02010004H
	mov	WORD PTR _keccakf_mod5$[ebp+8], 1027	; 00000403H
	mov	DWORD PTR tv1255[ebp], 22		; 00000016H
$LL24@k800_permu:

; 123  :   
; 124  :   for (rnd=0; rnd<22; rnd++) 
; 125  :   {
; 126  :     // Theta
; 127  :     for (i=0; i<5; i++) {     

	xor	ecx, ecx
	lea	eax, DWORD PTR [ebx+60]
$LL21@k800_permu:

; 128  :       bc[i] = st[i] 
; 129  :             ^ st[i +  5] 
; 130  :             ^ st[i + 10] 
; 131  :             ^ st[i + 15] 
; 132  :             ^ st[i + 20];

	mov	edx, DWORD PTR [eax-60]
	xor	edx, DWORD PTR [eax-40]
	xor	edx, DWORD PTR [eax-20]
	xor	edx, DWORD PTR [eax+20]
	xor	edx, DWORD PTR [eax]
	inc	ecx
	mov	DWORD PTR _bc$[ebp+ecx*4-4], edx
	add	eax, 4
	cmp	ecx, 5
	jb	SHORT $LL21@k800_permu

; 133  :     }
; 134  :     for (i=0; i<5; i++) {

	xor	edx, edx
	mov	esi, ebx
$LL18@k800_permu:

; 135  :       t = bc[keccakf_mod5[(i + 4)]] ^ ROTL32(bc[keccakf_mod5[(i + 1)]], 1);

	movzx	eax, BYTE PTR _keccakf_mod5$[ebp+edx+1]
	mov	eax, DWORD PTR _bc$[ebp+eax*4]
	movzx	ecx, BYTE PTR _keccakf_mod5$[ebp+edx+4]
	rol	eax, 1
	xor	eax, DWORD PTR _bc$[ebp+ecx*4]
	push	5
	mov	ecx, esi
	pop	edi
$LL15@k800_permu:

; 136  :       for (j=0; j<25; j+=5) {
; 137  :         st[j + i] ^= t;

	xor	DWORD PTR [ecx], eax
	add	ecx, 20					; 00000014H
	dec	edi
	jne	SHORT $LL15@k800_permu

; 133  :     }
; 134  :     for (i=0; i<5; i++) {

	inc	edx
	add	esi, 4
	cmp	edx, 5
	jb	SHORT $LL18@k800_permu

; 138  :       }
; 139  :     }
; 140  :     // Rho Pi
; 141  :     t = st[1];

	mov	edi, DWORD PTR [ebx+4]

; 142  :     for (i=0, r=0; i<24; i++) {

	xor	edx, edx
	xor	esi, esi
$LL12@k800_permu:

; 143  :       r += i + 1;
; 144  :       j = keccakf_piln[i];

	movzx	eax, BYTE PTR _keccakf_piln$[ebp+edx]

; 145  :       bc[0] = st[j];

	lea	eax, DWORD PTR [ebx+eax*4]
	mov	ecx, DWORD PTR [eax]
	lea	esi, DWORD PTR [esi+edx+1]
	mov	DWORD PTR _bc$[ebp], ecx

; 146  :       st[j] = ROTL32(t, r & 31);

	mov	ecx, esi
	and	ecx, 31					; 0000001fH
	rol	edi, cl
	inc	edx
	mov	DWORD PTR [eax], edi

; 147  :       t = bc[0];

	mov	edi, DWORD PTR _bc$[ebp]
	cmp	edx, 24					; 00000018H
	jb	SHORT $LL12@k800_permu

; 148  :     }
; 149  :     // Chi
; 150  :     for (j=0; j<25; j+=5) {

	push	5
	mov	eax, ebx
	pop	edx
$LL43@k800_permu:

; 151  :       for (i=0; i<5; i++) {
; 152  :         bc[i] = st[j + i];

	push	5
	pop	ecx
	mov	esi, eax
	lea	edi, DWORD PTR _bc$[ebp]
	rep movsd

; 153  :       }
; 154  :       for (i=0; i<5; i++) {

	xor	ecx, ecx
$LL3@k800_permu:

; 155  :         st[j + i] ^= (~bc[keccakf_mod5[(i + 1)]]) & bc[keccakf_mod5[(i + 2)]];

	movzx	esi, BYTE PTR _keccakf_mod5$[ebp+ecx+1]
	mov	esi, DWORD PTR _bc$[ebp+esi*4]
	movzx	edi, BYTE PTR _keccakf_mod5$[ebp+ecx+2]
	not	esi
	and	esi, DWORD PTR _bc$[ebp+edi*4]
	xor	DWORD PTR [eax], esi
	inc	ecx
	add	eax, 4
	cmp	ecx, 5
	jb	SHORT $LL3@k800_permu

; 148  :     }
; 149  :     // Chi
; 150  :     for (j=0; j<25; j+=5) {

	dec	edx
	jne	SHORT $LL43@k800_permu

; 156  :       }
; 157  :     }
; 158  :     // Iota
; 159  :     st[0] ^= rc(&lfsr);

	lea	eax, DWORD PTR _lfsr$[ebp]
	push	eax
	call	_rc
	xor	DWORD PTR [ebx], eax
	dec	DWORD PTR tv1255[ebp]
	pop	ecx
	jne	$LL24@k800_permu
	pop	edi
	pop	esi
	pop	ebx

; 160  :   }
; 161  : }

	leave
	ret	0
_k800_permute ENDP
_TEXT	ENDS
END
