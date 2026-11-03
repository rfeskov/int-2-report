#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <unistd.h>
#include <sys/syscall.h>
#include <linux/bpf.h>
int main(void){union bpf_attr a;memset(&a,0,sizeof a);a.map_type=BPF_MAP_TYPE_HASH;a.key_size=4;a.value_size=4;a.max_entries=1;
long r=syscall(SYS_bpf,BPF_MAP_CREATE,&a,sizeof a);printf("bpf -> %ld (%s)\n",r,r<0?strerror(errno):"OK");return r<0;}
