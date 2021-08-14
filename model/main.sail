default Order dec
$include <prelude.sail>
$include "utils.sail"

type regbits = bits(4)

register RIP : qword
register RAX : qword            /* 0 */
register RCX : qword            /* 1 */
register RDX : qword            /* 2 */
register RBX : qword            /* 3 */
register RSP : qword            /* 4 */
register RBP : qword            /* 5 */
register RSI : qword            /* 6 */
register RDI : qword            /* 7 */
register R8 : qword
register R9 : qword
register R10 : qword
register R11 : qword
register R12 : qword
register R13 : qword
register R14 : qword
register R15 : qword

register CF : flag
register PF : flag
register AF : flag
register ZF : flag
register SF : flag
register OF : flag

val rX : regbits -> qword effect {rreg}

function rX(r) =
  match r {
    0b0000 => RAX,
    0b0001 => RCX,
    0b0010 => RDX,
    0b0011 => RBX,
    0b0100 => RSP,
    0b0101 => RBP,
    0b0110 => RSI,
    0b0111 => RDI,
    0b1000 => R8,
    0b1001 => R9,
    0b1010 => R10,
    0b1011 => R11,
    0b1100 => R12,
    0b1101 => R13,
    0b1110 => R14,
    0b1111 => R15
  }

val wX : (regbits, qword) -> unit effect {wreg}

function wX(r, v) =
  match r {
    0b0000 => RAX = v,
    0b0001 => RCX = v,
    0b0010 => RDX = v,
    0b0011 => RBX = v,
    0b0100 => RSP = v,
    0b0101 => RBP = v,
    0b0110 => RSI = v,
    0b0111 => RDI = v,
    0b1000 => R8 = v,
    0b1001 => R9 = v,
    0b1010 => R10 = v,
    0b1011 => R11 = v,
    0b1100 => R12 = v,
    0b1101 => R13 = v,
    0b1110 => R14 = v,
    0b1111 => R15 = v
  }

overload X = {rX, wX}

struct MemoryOperand = {
  base : regbits,
  index : regbits,
  scale : int
}

val mem_operand_address : MemoryOperand -> qword effect {rreg}
function mem_operand_address (mem) = {
  let base = unsigned(X(mem.base));
  let index = unsigned(X(mem.index));
  let result = base + index * mem.scale;
  to_bits(64, result)
}

union RMOperand = {
  Memory : MemoryOperand,
  Register : regbits
}

val write_result : (RMOperand, qword) -> unit effect {wmem, wreg, rreg}

function write_result (operand, value) =
  match operand {
    Memory(mem) => write_mem(mem_operand_address(mem), sizeof(xlen_bytes), value),
    Register(reg) => X(reg) = value
  }

type byte_stream = list(byte)

enum rm_op = { MOV64 }

scattered union ast
val decode : byte_stream -> (byte_stream, ast) effect pure
val execute : ast -> unit effect {rmem, wmem, rreg, wreg}

union clause ast = RM : (regbits, RMOperand, rm_op)

val bits2_to_int : bits(2) -> int

function bits2_to_int(b) =
  match b {
    0b00 => 1,
    0b01 => 2,
    0b10 => 4,
    0b11 => 8
  }

function clause decode (0b01001 @ r : bits(1) @ x : bits(1) @ b : bits(1)) :: 0x8b :: (0b00 @ reg : bits(3) @ 0b100) :: (scale : bits(2) @ index : bits(3) @ base : bits(3)) :: stream2 =
  (stream2, RM (r @ reg, Memory(struct {
    base = b @ base, index = x @ index, scale = bits2_to_int(scale)
  }), MOV64))

function clause execute (RM (reg, operand, MOV64)) =
  write_result(operand, X(reg))
