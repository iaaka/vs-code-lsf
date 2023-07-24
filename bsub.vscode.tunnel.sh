#! /bin/bash -e


mem=${1:-40000}
cpu=${2:-4}
queue=${3:-normal}
gmem=${4:-6000}
name='vs-code-tunnel'
logpath=${HOME}/.vs-code-tunnel

mkdir -p $logpath

# set gpu parameters for gpu queues
gpu=''
if [[ $queue == *"gpu"* ]]
then
	gpu="-gpu \"mode=shared:j_exclusive=no:gmem=${gmem}:num=1\""
fi

# kill job if interupted

exitfn () {
    trap SIGINT              # Restore signal handling for SIGINT
    bkill $(bjobs  -o JOBID -J $name -noheader)
    exit                     #   then exit script.
}

trap "exitfn" INT            # Set up SIGINT trap to call function.

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
  $gpu \
  /usr/sbin/sshd -E ${logpath}/${name}-sshd.log -f /dev/null -D -p 5678 -h ${HOME}/.ssh/id_rsa
  bwait -w "started($name)"
fi

trap SIGINT
