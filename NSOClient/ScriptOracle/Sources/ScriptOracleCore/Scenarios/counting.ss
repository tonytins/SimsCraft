// Counting: a function called from a loop, and a condition joined with && and !.
// Main runs once a tick and returns, so it runs again on the second tick.
// @ticks 2
// @expect count = 212
integer count;

add(integer amount) {
    count += amount;
}

default {
    initialize() { count = 0; }
    main() {
        integer i = 3;
        while (i > 0) { add(2); i -= 1; }
        if (count >= 6 && !(count == 7)) { count += 100; }
    }
}
