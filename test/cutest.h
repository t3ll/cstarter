#ifndef CUTEST_SEEN
#define CUTEST_SEEN

typedef char * test_result;

#define PASS NULL

#define test(name) static test_result test_##name() 
#define do_assert(msg, test) do{if(!(test)) return msg;}while(0)
#define do_test(name) do{test_result msg=test_##name();if(msg) return msg;}while(0)
#define run_test(name) test_##name()
#define print_result(fd,result) do{if(result!=PASS){fprintf(fd,"FAILED | %s | %s\n", __FILE__, result);}else{fprintf(fd,"PASSED\n");}}while(0);
#define test_status(result) result!=PASS ? 1 : 0;

#endif 
