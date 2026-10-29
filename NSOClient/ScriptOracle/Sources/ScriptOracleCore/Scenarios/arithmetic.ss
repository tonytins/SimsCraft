// Arithmetic: SimAntics' 16-bit rules, which TSO's objects were written against.
// Values wrap past 32,767, dividing by zero gives -1, a remainder by zero leaves the value,
// and -7 % 3 gives 2.
// @ticks 0
// @expect wrapped = -32768
// @expect divided = -1
// @expect remainder = 7
// @expect negative = 2
// @expect masked = 2
integer wrapped;
integer divided;
integer remainder;
integer negative;
integer masked;

default {
    initialize() {
        wrapped = 32767 + 1;
        divided = 7 / 0;
        remainder = 7 % 0;
        negative = -7 % 3;
        masked = 6 & 3;
    }
}
