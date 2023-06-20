#! /bin/bash -e


queue=${1:-normal}
cpu=${2:-4}
mem=${1:-40000}

name='vs-code-tunnel'
logpath=${HOME}/.vs-code-tunnel

mkdir -p $logpath

jobhost=`bjobs  -o first_host -J ${name} -noheader 2> /dev/null`

if [ -z $jobhost ]
then
 bsub -J $name \
  -E "hostname" \
  -q $queue \
  -oo ${logpath}/${name}.out \
  -eo ${logpath}/${name}.err \
  -n $cpu \
  -M${mem} \
  -R "span[hosts=1] select[mem>${mem}] rusage[mem=${mem}]" \
  /usr/sbin/sshd -E ${logpath}/${name}-sshd.log -f /dev/null -D -p 5678 -h ${HOME}/.ssh/id_rsa
  bwait -w "started(vstunnel)"
fi
