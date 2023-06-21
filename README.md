# vs-code-lsf
This repo contains code and instructions on how to run [Visual Studio Code](https://code.visualstudio.com/) localy with all code executed on remote LSF cluster. It was inspired by discussion [here](https://github.com/microsoft/vscode-remote-release/issues/1722#issuecomment-1216040876).

# How to use
You'll need Visual Studio Code with installed `Remote` extension and ssh access to the head node of lsf cluster (it'll be referenced as `farm5` below) through vpn or ssh tunnel.
The idea is to run `sshd` server as lsf job and connect to it from Visual Studio using Remote SSH through the tunnel.
## Remote server (LSF)
Login to the head node, download bsub script and run it:
```
wget https://raw.githubusercontent.com/iaaka/vs-code-lsf/main/bsub.vscode.tunnel.sh
./bsub.vscode.tunnel.sh
```
The script should start the job nammed `vs-code-tunnel`. The script will not start the job if one is already running and it will wait untill job is started.
Queue, number of cores and memory can be specified as command line arguments (defaults are `normal`, `4` and `40000`).

## Local machine
First edit your `~/.ssh/config` by adding following lines:
```
Host farm5comp
  ProxyCommand ssh farm5 "nc \$(/software/lsf-farm5/10.1/linux3.10-glibc2.17-x86_64/bin/bjobs  -o first_host -J vs-code-tunnel -noheader) 5678"
  StrictHostKeyChecking no
  User <USER>
```
Replace  `<USER>` with your farm5 user name. Thanks to `ProxyCommand` this will allow to determine host name by job name (note `vs-code-tunnel` matches job name from bsub script.)
You can check whether it works by 
```
ssh farm5comp
```
If everything is allright it should send you to the compute node.
Now launch Visual Studio, go to Remote SSH extension, chose farm5comp and voila!

# Future development
## Start job on connect
## Vs-code launcher
## Multiple sessions

# Alternatives
## code-server
There is server version of vs-code (opensource branch) that can be accessed through the browser. See [docker](https://hub.docker.com/r/linuxserver/code-server).
