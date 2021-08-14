/* Most of this file is taken from sail-riscv project: https://github.com/rems-project/sail-riscv */
type xlen : Int = 64
type xlen_bytes : Int = 8

type flag = bits(1)
type byte = bits(8)
type qword = bits(64)

val EXTZ : forall 'n 'm, 'm >= 'n. (implicit('m), bits('n)) -> bits('m)
function EXTZ(m, v) = sail_zero_extend(v, m)

val to_bits : forall 'l, 'l >= 0.(atom('l), int) -> bits('l)
function to_bits (l, n) = get_slice_int(l, n, 0)

val MEMr = {lem: " MEMr" , coq: " MEMr" , _: " read_ram" }: forall ('n 'm : Int), 'n >= 0.
  (int('m), int('n), bits('m), bits('m)) -> bits(8 * 'n) effect {rmem}

val read_mem : forall 'n, 'n >= 0. (qword, int('n)) -> bits(8 * 'n) effect {rmem}
function read_mem(addr, width) =
    MEMr(sizeof(xlen), width, EXTZ(0x0), addr)

val MEMval = {lem: " MEMval" , coq: " MEMval" , _: " write_ram" }: forall ('n 'm : Int), 'n >= 0.
  (int('m), int('n), bits('m), bits('m), bits(8 * 'n)) -> unit effect {wmem}

val write_mem : forall 'n, 'n >= 0. (qword, int('n), bits(8 * 'n)) -> unit effect {wmem}
function write_mem(addr, width, value) =
    MEMval(sizeof(xlen), width, EXTZ(0x0), addr, value)
