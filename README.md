# vs-code-lsf
This repo contains code and instructions on how to run [Visual Studio Code](https://code.visualstudio.com/) localy with all code executed on remote LSF cluster. It was inspired by discussion [here](https://github.com/microsoft/vscode-remote-release/issues/1722#issuecomment-1216040876).

# Instructions
## Preparations
This part is about what you need to do just once. Section `Usage` below shows how to start vs-code and connect to the jobs once everytinh is set up.

You'll need Visual Studio Code with installed `Remote - SSH` extension and ssh access to the head node of lsf cluster (it'll be referenced as `farm22` below) through vpn or ssh tunnel if necessary.
The idea is to run `sshd` server as lsf job and connect to it from Visual Studio using `Remote - SSH`.

### Remote server (LSF)
Login to the head node, download bsub script and run it:
```
wget --no-cache https://raw.githubusercontent.com/iaaka/vs-code-lsf/main/bsub.vscode.tunnel.sh
chmod +x bsub.vscode.tunnel.sh
./bsub.vscode.tunnel.sh
```
The script should start the job nammed `vs-code-tunnel`. The script will not start the job if one is already running and it will wait untill job is started.

### Local machine
First edit your `~/.ssh/config` by adding following lines:
```
Host farm22comp
  ProxyCommand ssh farm22 "nc \$(/software/lsf-farm22/10.1/linux3.10-glibc2.17-x86_64/bin/bjobs  -o first_host -J vs-code-tunnel -noheader) 5678"
  StrictHostKeyChecking no
  User <USER>
```
Replace  `<USER>` with your farm user name. Thanks to `ProxyCommand` this will allow to determine host name by job name (note `vs-code-tunnel` matches job name from bsub script.)
You can check whether it works by: 
```
ssh farm22comp
```
If everything is allright it should send you to the compute node.

## Usage
Login on head node and run (if it was not done before):
```
./bsub.vscode.tunnel.sh
```
The script should start the job nammed `vs-code-tunnel`. The script will not start the job if one is already running and it will wait untill job is started.
Memory, queue, number of cores can be specified as command line arguments. Defaults (`4` (*1000M), `normal`, and `1`) can be changed by:
```
./bsub.vscode.tunnel.sh 10 yesterday 2
```
This command will requests 10000M with 2 cores in `yesterday` queue.

Now launch vs-code on your local machine, go to Remote SSH extension, chose farm22comp and voila!

### GPU 
You may alsospecify gmem if you are using gpu-queues (ones that contains `gpu` in their mames). The default is 6 (*1000M), it can be changed by fourth parameter:
```
./bsub.vscode.tunnel.sh 2 gpu-normal 1 3
```
This command will requests 2000M RAM, 3000M gmem, and 1 core in `gpu-normal` queue.

## Cleanup
It is better to kill job when you stop working with Visual Studio to release resources. You can do it by:
```
bkill $(bjobs  -o JOBID -J vs-code-tunnel -noheader)
```

# Future development
1. Make lsf job start on Visual Studio connect (I have tried `RemoteCommand` in ssh config, but so far unsuccesfully)
2. Other option can be to make local Visual Studio launcher that first starts the job and then launches Visual Studio. Probably [this](https://scicomp.ethz.ch/wiki/VSCode) is relevant.
3. Add suppots for multiple sessions (with different resources) simultaneously. Possible interference of multiple sshd running on the same node? Job names needs to be diversified.  

# Alternatives
1. [code-server](https://github.com/coder/code-server) is server version of vs-code (opensource branch) that can be accessed through the browser. See [docker](https://hub.docker.com/r/linuxserver/code-server). In can be run on farm by running following code in interactive session:
```
/software/singularity-v3.9.0/bin/singularity exec \
  -B /nfs,/lustre,/software \
  --home /tmp/$(whoami) \
  --cleanenv \
  --env HOST=$(hostname) \
  /nfs/cellgeni/pasham/singimage/codeserver.sif \
  /bin/bash -c "export XDG_DATA_HOME=/nfs/cellgeni/pasham;export PASSWORD=ppp;/app/code-server/bin/code-server --bind-addr ${HOST}:8443"
```
and then conecting to ${HOST}:8443 (where ${HOST} is the node where job is running) from browser. However I didn't manage to make majority of important features to work (r/pyrhon graphics for example)
