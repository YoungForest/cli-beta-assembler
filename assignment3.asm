||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||| 6.004 BETA Macro package -                          3/10/94 SAW  |||
|||  This version defines our 32-bit Alpha-like RISC.                |||
||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

| Global instruction definition conventions:
|  * DESTINATION arg is LAST

| Instruction set summary.  Notation:
| ra, rb, rc: registers
|         CC: 16-bit signed constant
|      label: statement/location tag (becomes PC-relative offset)

| ADD(RA, RB, RC)	| RC <- <RA> + <RB>
| ADDC(RA, C, RC)	| RC <- <RA> + C
| AND(RA, RB, RC)	| RC <- <RA> & <RB>
| ANDC(RA, C, RC)	| RC <- <RA> & C
| MUL(RA, RB, RC)	| RC <- <RA> * <RB>
| MULC(RA, C, RC)	| RC <- <RA> * C
| DIV(RA, RB, RC)	| RC <- <RA> / <RB>
| DIVC(RA, C, RC)	| RC <- <RA> / C
| OR( RA, RB, RC)	| RC <- <RA> | <RB>
| ORC(RA,  C, RC)	| RC <- <RA> | C
| SHL(RA, RB, RC)	| RC <- <RA> << <RB>
| SHLC(RA, C, RC)	| RC <- <RA> << C
| SHR(RA, RB, RC)	| RC <- <RA> >> <RB>
| SHRC(RA, C, RC)	| RC <- <RA> >> C
| SRA(RA, RB, RC)	| RC <- <RA> >> <RB>
| SRAC(RA, C, RC)	| RC <- <RA> >> C
| SUB(RA, RB, RC)	| RC <- <RA> - <RB>
| SUBC(RA, C, RC)	| RC <- <RA> - C
| XOR(RA, RB, RC)	| RC <- <RA> ^ <RB>
| XORC(RA, C, RC)	| RC <- <RA> ^ C

| CMPEQ(RA, RB, RC)	| RC <- <RA> == <RB>
| CMPEQC(RA, C, RC)	| RC <- <RA> == C
| CMPLE(RA, RB, RC)	| RC <- <RA> <= <RB>
| CMPLEC(RA, C, RC)	| RC <- <RA> <= C
| CMPLT(RA, RB, RC)	| RC <- <RA> <  <RB>
| CMPLTC(RA, C, RC)	| RC <- <RA> <  C


| BR(LABEL,RC)		| RC <- <PC>+4; PC <- LABEL (PC-relative addressing)
| BR(LABEL)		| PC <- LABEL (PC-relative addressing)
| BEQ(RA, LABEL, RC)	| RC <- <PC>+4; IF <RA>==0 THEN PC <- LABEL
| BEQ(RA, LABEL)	| IF <RA>==0 THEN PC <- LABEL
| BF(RA, LABEL, RC)	| RC <- <PC>+4; IF <RA>==0 THEN PC <- LABEL
| BF(RA, LABEL)		| IF <RA>==0 THEN PC <- LABEL
| BNE(RA, LABEL, RC)	| RC <- <PC>+4; IF <RA>!=0 THEN PC <- LABEL
| BNE(RA, LABEL)	| IF <RA>!=0 THEN PC <- LABEL
| BT(RA, LABEL, RC)	| RC <- <PC>+4; IF <RA>!=0 THEN PC <- LABEL
| BT(RA, LABEL)		| IF <RA>!=0 THEN PC <- LABEL
| JMP(RA, RC)		| RC <- <PC>+4; PC <- <RA> & 0xFFFC
| JMP(RB)		| PC <- <RB> & 0xFFFC

| LD(RA, CC, RC)	| RC <- <<RA>+CC>
| LD(CC, RC)		| RC <- <CC>
| ST(RC, CC, RA)	| <RA>+CC <- <RC>
| ST(RC, CC)		| CC <- <RC>
| LDR(CC, RC)		| RC <- <CC> (PC-relative addressing)

| MOVE(RA, RC)		| RC <- <RA>
| CMOVE(CC, RC)		| RC <- CC
| HALT()		| STOPS SIMULATOR.

| PUSH(RA)		| (2) <SP> <- <RA>; SP <- <SP> - 4
| POP(RA)		| (2) RA <- <<SP>+4>; SP <- <SP> + 4
| ALLOCATE(N)		| Allocate N longwords from stack
| DEALLOCATE(N)		| Release N longwords

| CALL(label)		| Call a subr; save PC in lp.
| CALL(label, n)	| (2) Call subr at label with n args.
			| Saves return adr in LP.
			| Pops n longword args from stack.

| RTN()			| Returns to adr in <LP> (Subr return)
| XRTN()		| Returns to adr in <IP> (Intr return)

| WORD(val)		| Assemble val as a 16-bit datum
| LONG(val)		| Assemble val as a 32-bit datum
| STORAGE(NWORDS)	| Reserve NWORDS 32-bit words of DRAM

| GETFRAME(F, RA)	| RA <- <<BP>+F>
| PUTFRAME(RA, F)	| <BP>+F <- <RA>

| Calling convention:
|	PUSH(argn-1)
|	...
|	PUSH(arg0)
|	CALL(subr, nargs)
|	(return here with result in R0, args cleaned)

| Extra register conventions, for procedure linkage:
| LP = 28			| Linkage register (holds return adr)
| BP = 29			| Frame pointer (points to base of frame)

| Conventional stack frames look like:
|	arg[N-1]
|	...
|	arg[0]
|	<saved lp>
|	<saved bp>
|	<other saved regs>
|   BP-><locals>
|       ...
|   SP->(first unused location)

| Convention: define a symbol for each arg/local giving bp-relative offset.
| Then use
|   getframe(name, r) gets value at offset into register r.
|   putframe(r, name) puts value from r into frame at offset name


||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||| End of documentation.  Following are the actual definitions...   |||
||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

| Assemble words, little-endian:
.macro WORD(x) x%0x100 (x>>8)%0x100 
.macro LONG(x) WORD(x) WORD(x >> 16)	| little-endian for Maybe
.macro STORAGE(NWORDS)	. = .+(4*NWORDS)| Reserve NWORDS words of RAM


| register designators
| this allows symbols like r0, etc to be used as
| operands in instructions. Note that there is no real difference
| in this assembler between register operands and small integers.

r0 = 0
r1 = 1
r2 = 2
r3 = 3
r4 = 4
r5 = 5
r6 = 6
r7 = 7
r8 = 8
r9 = 9
r10 = 10
r11 = 11
r12 = 12
r13 = 13
r14 = 14
r15 = 15
r16 = 16
r17 = 17
r18 = 18
r19 = 19
r20 = 20
r21 = 21
r22 = 22
r23 = 23
r24 = 24
r25 = 25
r26 = 26
r27 = 27
r28 = 28
r29 = 29
r30 = 30
r31 = 31

bp = 27			| frame pointer (points to base of frame)
lp = 28			| linkage register (holds return adr)
sp = 29			| stack pointer (points to 1st free locn)
xp = 30			| interrupt return pointer (lp for interrupts)


| understand upper case, too.
R0 = r0
R1 = r1
R2 = r2
R3 = r3
R4 = r4
R5 = r5
R6 = r6
R7 = r7
R8 = r8
R9 = r9
R10 = r10
R11 = r11
R12 = r12
R13 = r13
R14 = r14
R15 = r15
R16 = r16
R17 = r17
R18 = r18
R19 = r19
R20 = r20
R21 = r21
R22 = r22
R23 = r23
R24 = r24
R25 = r25
R26 = r26
R27 = r27
R28 = r28
R29 = r29
R30 = r30
R31 = r31
XP = xp
LP = lp
BP = bp
SP = sp

.macro betaop(OP,RA,RB,RC) {
      .align 4
      LONG((OP<<26)+((RC%0x20)<<21)+((RA%0x20)<<16)+((RB%0x20)<<11)) }

.macro betaopc(OP,RA,CC,RC) {
      .align 4
      LONG((OP<<26)+((RC%0x20)<<21)+((RA%0x20)<<16)+(CC%0x10000)) }


.macro ADD(RA, RB, RC)		betaop(0x20,RA,RB,RC)
.macro ADDC(RA, C, RC)		betaopc(0x30,RA,C,RC)

.macro AND(RA, RB, RC)		betaop(0x28,RA,RB,RC)
.macro ANDC(RA, C, RC)		betaopc(0x38,RA,C,RC)
.macro MUL(RA, RB, RC)		betaop(0x22,RA,RB,RC)
.macro MULC(RA, C, RC)		betaopc(0x32,RA,C,RC)
.macro DIV(RA, RB, RC)		betaop(0x23,RA,RB,RC)
.macro DIVC(RA, C, RC)		betaopc(0x33,RA,C,RC)
.macro OR( RA, RB, RC)		betaop(0x29,RA,RB,RC)
.macro ORC(RA,  C, RC)		betaopc(0x39,RA,C,RC)
.macro SHL(RA, RB, RC)		betaop(0x2C,RA,RB,RC)
.macro SHLC(RA, C, RC)		betaopc(0x3C,RA,C,RC)
.macro SHR(RA, RB, RC)		betaop(0x2D,RA,RB,RC)
.macro SHRC(RA, C, RC)		betaopc(0x3D,RA,C,RC)
.macro SRA(RA, RB, RC)		betaop(0x2E,RA,RB,RC)
.macro SRAC(RA, C, RC)		betaopc(0x3E,RA,C,RC)
.macro SUB(RA, RB, RC)		betaop(0x21,RA,RB,RC)
.macro SUBC(RA, C, RC)		betaopc(0x31,RA,C,RC)
.macro XOR(RA, RB, RC)		betaop(0x2A,RA,RB,RC)
.macro XORC(RA, C, RC)		betaopc(0x3A,RA,C,RC)

.macro CMPEQ(RA, RB, RC)	betaop(0x24,RA,RB,RC)
.macro CMPEQC(RA, C, RC)	betaopc(0x34,RA,C,RC)
.macro CMPLE(RA, RB, RC)	betaop(0x26,RA,RB,RC)
.macro CMPLEC(RA, C, RC)	betaopc(0x36,RA,C,RC)
.macro CMPLT(RA, RB, RC)	betaop(0x25,RA,RB,RC)
.macro CMPLTC(RA, C, RC)	betaopc(0x35,RA,C,RC)

.macro BETABR(OP,RA,RC,LABEL)	betaopc(OP,RA,((LABEL-.)>>2)-1, RC)
.macro BEQ(RA, LABEL, RC)	BETABR(0x1D,RA,RC,LABEL)
.macro BEQ(RA, LABEL)		BETABR(0x1D,RA,r31,LABEL)
.macro BF(RA, LABEL, RC)	BEQ(RA,LABEL,RC)
.macro BF(RA,LABEL)		BEQ(RA,LABEL)
.macro BNE(RA, LABEL, RC)	BETABR(0x1E,RA,RC,LABEL)
.macro BNE(RA, LABEL)		BETABR(0x1E,RA,r31,LABEL)
.macro BT(RA,LABEL,RC)		BNE(RA,LABEL,RC)
.macro BT(RA,LABEL)		BNE(RA,LABEL)
.macro BR(LABEL,RC)		BEQ(r31, LABEL, RC)
.macro BR(LABEL)		BR(LABEL, r31)
.macro JMP(RA, RC)		betaopc(0x1B,RA,0,RC)
.macro JMP(RA)			betaopc(0x1B,RA,0,r31)

.macro LD(RA, CC, RC)		betaopc(0x18,RA,CC,RC)
.macro LD(CC, RC)		betaopc(0x18,R31,CC,RC)
.macro ST(RC, CC, RA)		betaopc(0x19,RA,CC,RC)
.macro ST(RC, CC)		betaopc(0x19,R31,CC,RC)
.macro LDR(CC, RC)		BETABR(0x1F, R31, RC, CC)

.macro MOVE(RA, RC)		ADD(RA, R31, RC)
.macro CMOVE(CC, RC)		ADDC(R31, CC, RC)

.macro PUSH(RA)		ADDC(SP,4,SP)  ST(RA,-4,SP)
.macro POP(RA)		LD(SP,-4,RA)   ADDC(SP,-4,SP)

.macro CALL(label)	BR(label, LP)
			
.macro RTN()		JMP(LP)
.macro XRTN()		JMP(XP)

| Controversial Extras
| Calling convention:
|	PUSH(argn-1)
|	...
|	PUSH(arg0)
|	CALL(subr, nargs)
|	(return here with result in R0, args cleaned)

| Extra register conventions, for procedure linkage:
| LP = 28			| Linkage register (holds return adr)
| BP = 29			| Frame pointer (points to base of frame)

| Conventional stack frames look like:
|	arg[N-1]
|	...
|	arg[0]
|	<saved lp>
|	<saved bp>
|	<other saved regs>
|   BP-><locals>
|       ...
|   SP->(first unused location)

| Convention: define a symbol for each arg/local giving bp-relative offset.
| Then use
|   getframe(name, r) gets value at offset into register r.
|   putframe(r, name) puts value from r into frame at offset name


.macro GETFRAME(OFFSET, REG) LD(bp, OFFSET, REG)
.macro PUTFRAME(REG, OFFSET) ST(REG, OFFSET, bp)
.macro CALL(S,N) BR(S,lp) SUBC(sp, 4*N, sp)

.macro ALLOCATE(N) ADDC(sp, N*4, sp)
.macro DEALLOCATE(N) SUBC(sp, N*4, sp)

|--------------------------------------------------------
| Privileged mode instructions
|--------------------------------------------------------

.macro PRIV_OP(FNCODE)		betaopc (0x00, 0, FNCODE, 0)
.macro HALT() PRIV_OP (0)
.macro RDCHAR() PRIV_OP (1)
.macro WRCHAR() PRIV_OP (2)
.macro CYCLE()	PRIV_OP (3)
.macro TIME()	PRIV_OP (4)
.macro CLICK()	PRIV_OP (5)
.macro RANDOM()	PRIV_OP (6)
.macro SEED()	PRIV_OP (7)
.macro SERVER() PRIV_OP (8)

| SVC calls; used for OS extensions

.macro SVC(code)		betaopc (0x01, 0, code, 0)

| Trap and interrupt vectors
VEC_RESET	= 0		| Reset (powerup)
VEC_II		= 4		| Illegal instruction (also SVC call)
VEC_CLK		= 8		| Clock interrupt
VEC_KBD		= 12		| Keyboard interrupt
VEC_MOUSE	= 16		| Mouse interrupt

| constant for the supervisor bit in the PC
PC_SUPERVISOR	   = 0x80000000		| the bit itself
PC_MASK            = 0x7fffffff		| a mask for the rest of the PC

Begin:
ADDC(r31, 100, r0) | r0 = 100/0x64
ADDC(r0, 10, r1)     | r1 = 110/0x6e
ADD(r0,r1,r2)          | r2 = 210/0xd2
ADDC(r1, 100, r1)       | r1 = 210/0xd2
CMPLE(r0, r1, r4)  | r4 = 1
CMPLE(r1, r2, r5)  | r5 = 1
CMPLE(r2, r0, r6)  | r6 = 0
ADDC(r31, 6, r7)   | r7 = 6
ORC(r7, 3, r8)        | r8 = 7
ORC(r31, 4, r9)     | r9 = 4
ST(r8, 4, r9)       | mem[4 + 4] = 7
LD(r9, 4, r10)     | r10 = 7
BNE(r11, Begin, r12) | no jump, r12 = 34
ADDC(r13, 1, r13)     | r13++
BNE(r13, Begin, r15) | jump to Begin, r15 = 3C


