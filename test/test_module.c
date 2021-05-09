#include <stdio.h>

#include "cutest.h"
#include "src/module.h"

test(plus) {
    do_assert("plus(3, 7) should equal 10", plus(3,7) == 12);
    return PASS;
}

test(every) {
    do_test(plus);
    return PASS;
}

int main(void) {
    test_result r = run_test(every);
    print_result(stdout, r);
    return test_status(r);
}
