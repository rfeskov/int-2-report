#!/usr/bin/env bash
STAGE=${1:?stage}
OUT=~/lab/results/${STAGE}_$(uname -m).tsv
T=~/lab/tools
: >"$OUT"
: >"$OUT.info"
t() {
  local n=$1
  shift
  local o rc st
  o=$( (timeout 20 bash -c '"$@"' _ "$@") 2>&1)
  rc=$?
  o=$(printf '%s' "$o" | tr '\r\n\t' '   ' | cut -c1-70)
  [ $rc -eq 0 ] && st=OK || st=BLOCKED
  printf '%s\t%s\t%s\n' "$n" "$st" "$o" | tee -a "$OUT"
}
kallsyms() { sudo grep -m1 ' _text$' /proc/kallsyms | grep -qv '^0000000000000000'; }
iouring() { python3 -c 'import ctypes,sys;l=ctypes.CDLL(None,use_errno=True);r=l.syscall(425,4,ctypes.create_string_buffer(120));sys.exit(0 if r>=0 else ctypes.get_errno())'; }
modload() { sudo modprobe dummy && sudo modprobe -r dummy; }
kexecl() { sudo kexec -l /boot/vmlinuz-$(uname -r) --initrd=/boot/initrd.img-$(uname -r) --reuse-cmdline && sudo kexec -u; }
kcore() { sudo head -c 4 /proc/kcore >/dev/null; }
sysok() {
  s=$(systemctl is-system-running)
  [ "$s" = running ] || [ "$s" = degraded ]
}
export -f kallsyms iouring modload kexecl kcore sysok
t dmesg_user dmesg
t kallsyms_root kallsyms
t perf_user perf stat -e task-clock true
t bpf_user $T/bpf_demo
t ptrace_child $T/ptrace_demo
t userns unshare -Ur true
t bwrap bwrap --unshare-user --ro-bind / / true
t io_uring iouring
t modprobe modload
t kexec_load kexecl
t proc_kcore kcore
t ctl_dns getent hosts deb.debian.org
t ctl_https curl -s -o /dev/null --max-time 10 -w 'http=%{http_code}' https://deb.debian.org
t ctl_systemd sysok
{
  echo "## cmdline"
  cat /proc/cmdline
  echo "## lockdown"
  cat /sys/kernel/security/lockdown
} >>"$OUT.info"
sysctl kernel.dmesg_restrict kernel.kptr_restrict kernel.perf_event_paranoid kernel.unprivileged_bpf_disabled kernel.yama.ptrace_scope user.max_user_namespaces kernel.io_uring_disabled kernel.modules_disabled kernel.kexec_load_disabled >>"$OUT.info" 2>&1
