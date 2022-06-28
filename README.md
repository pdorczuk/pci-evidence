# pci-evidence
Collection of scripts to collect PCI DSS evidence from a variey of servers and platforms.

As an external auditor, one of the most frequent questions that I get from clients is "How should I provide evidence?" Ask 5 administrators this question and you will get 5 different answers. Because I want to automate everything, it makes sense to standardize on evidence requests so that I get a predictable output that I can feed into scripts. I have a few limitations imposed by my work and those are, 1. I can't touch the system myself, even read-only, and 2. I am not allowed to ask a client to install any tools so I can't rely on third-party tools or libraries (jq for example).

## Command structure
I want to take a second and explain some common patterns you'll see in all the different scripts. It is not enough to have the command output, as an auditor, I am also looking for metadata about evidence like what command produced the output, what system the command was performed on, and when it was ran. The majority of the scripts are Linux Shell so I'll start with that. First off, all the scripts are enclosed in: ``` set -x ...commands... set +x ``` This setting causes each command to be echoed to STDOUT. This is important so that when auditing, we can verify the output that we are looking at. Next, we always include the ``` hostname ``` and ``` date ``` commands to show where and when the script was ran.

In Windows, I wrap the script in ``` Start-Transcript ...commands... Stop-Transcript ``` which causes Windows to output all the needed metadata including the hostname, date, and commands ran.
