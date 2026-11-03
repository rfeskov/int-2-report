#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <signal.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/ptrace.h>
int main(void) {
    pid_t p = fork();
    if (p == 0) { execl("/bin/sleep", "sleep", "60", NULL); _exit(1); }
    sleep(1);
    long r = ptrace(PTRACE_ATTACH, p, 0, 0);
    printf("ptrace(ATTACH) -> %ld (%s)\n", r, r < 0 ? strerror(errno) : "OK");
    kill(p, SIGKILL);
    return r < 0;
}
