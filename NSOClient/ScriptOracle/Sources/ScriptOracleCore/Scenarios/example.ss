integer count;

add(integer amount) {
    count += amount;
}

default {
    initialize() { count = 0; }
    main() {
        integer i = 3;
        while (i > 0) { add(2); i -= 1; }
        if (count >= 6 && !(count == 7)) { refresh(); }
    }
}
