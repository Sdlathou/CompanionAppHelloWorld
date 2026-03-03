# Usage of the basic infrastructure service with the Slices CLI

This guide explains how to use the IDLab basic infrastructure service for your thesis project.
Managing this basic infrastructure service is done through the Slices CLI of the Slices platform.
Make sure that this CLI is installed and that you have an active experiment, by following the steps outlined [here](README.md#slices-cli).
Please read through all sections listed in the table of contents below.

[[_TOC_]]

## Setting the environment variables for the Slices CLI

When using the Slices CLI to reserve and manage server resources on the basic infrastructure service, it is important to set some environment variables. This is also already done by the [`create-experiment.sh`](create-experiment.sh) script, but you will need to set them in every new shell process as they are not remembered. Run the following:

```shell
export SLICES_BI_SITE_ID="be-gent1-bi-vm1"
export SLICES_EXPERIMENT="thesis-senne2026-exp"
```

To save them across shell sessions, you can add these commands at the bottom of the `~/.bashrc` script (which is executed each time you open a new shell session).

## Reservation of server resources

The process of reserving a server resource on the basic infrastructure service is described starting from [this page of the Slices CLI documentation](https://doc.slices-ri.eu/BasicServices/BasicInfrastructure/first_machine.html).
We recommend you to read through this documentation, to understand how everything works.

### Things to take into account before reserving

Before you start reserving any server resources (and thus executing commands with the Slices CLI), we want you to take the following into account:
- You are only allowed to make use of the `be-gent1-bi-vm1` site, i.e. of the VM infrastructure. The bare metal infrastructure (site ID `be-gent1-bi-baremetal1`) should not be used, unless you receive explicit permission from your promotors to do so. If you have correctly followed the steps in [this section](#setting-the-environment-variables-for-the-slices-cli), you should have already executed `export SLICES_BI_SITE_ID="be-gent1-bi-vm1"` in your Python venv with the Slices CLI installed, such that the correct site is used in the current session. You can verify this by running `echo $SLICES_BI_SITE_ID`.
- The different flavors of VM that are available can be listed through `slices bi flavor list`. Each flavor has different specifications associated to it. Please only reserve the flavors and number of servers that have been agreed upon with your promotors. If you do need more servers and/or better flavors, ask your promotors first.
- Adding a public IPv4 address to a server node, by appending the `--public-ipv4` when reserving a resource, is only allowed once per project. If you need more than 1 public IPv4, this can be requested with a proper motivation. Never do so without receiving permission from your promotors. Note that you don't need a public IPv4 for different VMs to communicate with each other, as explained [here](#communication-between-multiple-servers).
- You are free to use any disk image for your server(s) that is available via `slices bi diskimage list`. 
- Any reserved server will always have a primary disk partition that occupies the full disk space. This means that you won't be able to store more data than available according to the `df -h` command.

### How to reserve a server

Before starting to reserve a server, make sure that the `SLICES_BI_SITE_ID` environment variable is correctly set in the shell you work in. If you properly followed [these instructions](#setting-the-environment-variables-for-the-slices-cli), this should be fine. Verify with `echo $SLICES_BI_SITE_ID` and execute `export SLICES_BI_SITE_ID="be-gent1-bi-vm1"` if this is not set.

To perform the reservation of a single server, you can use the [`setup-server.sh`](setup-server.sh) script. Some notes about this script:
- Before running it, make sure to update the parameters at the top.
- The script requests a server resource within your experiment, waits until it is ready, and prints the SSH command through which you can access the created server.
- The reserved server immediately has the maximum duration of 89 days. This will automatically extend the experiment duration to 89 days as well. If you would not need the server anymore at some point, you can just release the server resources as described [here](#releasing-the-server-resources).

If you have been given permission to create more than 1 server resource at the same time, you can use the same script. Take the following into account:
- Change the `SERVER_NAME` parameter, as the server name should be unique within an experiment.
- Do not set `USE_PUBLIC_IP` parameter to `true` for additional servers.

There is no need to work with multiple experiments. All servers you use will thus be reserved in the same experiment.

### Additional tools for server reservation

The previous two sections tell you everything you should know to reserve a server on the basic infrastructure service in the regular way.
However, as you can read on the documentation, the basic infrastructure service offers additional tools that help you with configuring your resources.

- [Cloud-init](https://doc.slices-ri.eu/BasicServices/BasicInfrastructure/cloud-init.html): we won't go into detail on this as it's not required, but you are allowed to experiment with it if you wish.
- [Resource specifications](https://doc.slices-ri.eu/BasicServices/BasicInfrastructure/resource_spec.html): fancier resource specifications are possible when reserving resources. However, you will likely not need these configurations. Note that you do not need to set up any explicit links between servers (if you would have 2 or more that need to communicate); this is only useful if you are doing very specific experiments for research. If you think certain features are useful, ask your promotors to be sure about how to proceed.

## Accessing your server over SSH

Accessing your server is possible via an SSH connection. [This part of the Slices CLI documentation](https://doc.slices-ri.eu/BasicServices/BasicInfrastructure/first_machine.html#accessing-the-machine) explains how to do this. In this section, a short summary is given.

Depending on whether you have configured a public IPv4 for your server or not, the SSH command differs. You can print the SSH command by running the following command:

```shell
slices bi ssh <server_name> --show command --no-exec
```

You can execute this command in any terminal supporting regular command line SSH.
Note that you will only be able to access the server if your public SSH key is added as an authorized key to the server.
- For the person who created this server, the SSH key is automatically added (provided that you ran the `slices pubkey register <public_ssh_key_path>` command during the [installation of the Slices CLI](README.md#installation-instructions))
- For any other team member that also needs access to the server, their SSH key needs to be added explicitly. How to do so is explained [here](account-project-setup.md#register-team-members-ssh-key-to-server).

## Initial set-up of your reserved Ubuntu or Debian server

For any Ubuntu or Debian server, it is recommended to update all packages before you start working on the server, by executing the following commands:

```shell
sudo apt update
sudo apt dist-upgrade
sudo apt autoremove -y
```

Reboot after this.

## Rebooting a server resource

Rebooting a server resource is possible in 2 ways:
- Via `sudo reboot now` on the command line when logged in over SSH. This will close the SSH connection.
- Directly via the Slices CLI through `slices bi reset <server_name>` (where `<server_name>` should be replaced by the value in the `Name` column of the output of the `slices bi list-resources` command)

In both case, you can use the command `slices bi list-resources` to monitor when the server resource is back up. The `Status` column of the output should state `up` for the rebooted resource. Once this is shown, you can SSH into it again.

We advise to **never reboot before making sure all data on storage and in memory of running services is backed up**. You are working with virtual machines, so you can very easily lose data here. Also take a look at the [section about data management and backups](#data-management-and-back-ups) to have this automatically configured.

## Experiment and server management with Slices CLI

Managing your project's experiments and resources (servers) can be done with the Slices CLI.

### Listing existing experiments and resources

You can get an overview of the available experiments and server resources within an experiment through the following commands:

```shell
# list all experiments in the project that you are a member of
slices experiment list
# list all resources in an experiment
# (you can leave out the "--experiment" flag if you have correctly set
#  the SLICES_EXPERIMENT environment variable)
slices bi list-resources --experiment <experiment>
```

Normally, you should not have more than 1 experiment.
Both the returned list of experiments and resources contain a column `Expires At` which is very important: it defines the time until expiry, after which you lose your machine (and all data on it that is not backed up). Take a look at the [next section about extending your resources' lifetime](#extending-your-resources-lifetime) to avoid this from happening.

### Extending your resources' lifetime

**It is your responsibility to extend your resources' duration before it expires, otherwise you will lose everything that is not backed up**.
[This section of the Slices CLI documentation](https://doc.slices-ri.eu/BasicServices/BasicInfrastructure/first_machine.html#extending-the-lifetime-of-your-machine) explains how to extend the lifetime of a certain resource. You should do this with the following command:

```shell
slices bi extend <server_name> --duration 89d
```

For the parameters, take into account the following:
- `<server_name>` should be replaced by the value in the `Name` column of the output of the `slices bi list-resources` command shown [here](#listing-existing-experiments-and-resources)
- In terms of duration, feel free to specify another number of days, but be aware that 89 is the maximum. The number of days always represents the duration from the current time, and cannot be smaller than the remaining time until the current expiry time.

Note that both resources and experiments have a duration. However, there is no need to extend the lifetime of your experiment yourself: when you extend a server resource beyond the current expiration time of the experiment it is part of, the experiment will be extended until the new expiry of this server resource.

**We advise you to put a reminder to regularly update the duration of your server resources**, even if they are not yet close to expiry. This way, you won't forget about it. **Make sure your server resources do not expire before you are done with your thesis!**

### Releasing the server resources

If you will not be using a server anymore, you should release the reserved resources. This can be because you no longer need it, or because you cannot reach your server anymore. **Make sure you do not forget this, as otherwise you might be using multiple server nodes and/or public IPs**.

To release the resources, run the following command with the Slices CLI:

```shell
slices bi destroy <server_name> --experiment <experiment>
```

In this command, `<server_name>` should be replaced by the value in the `Name` column of the output of the `slices bi list-resources` command shown [here](#listing-existing-experiments-and-resources).

Note that your experiment, even if it does not contain any resources anymore, will not disappear from the list of experiments until it expires.

## Data management and back-ups

Since you work on a research infrastructure with virtual machines, the disks of your server are not permanent and things can go wrong. This means that you lose all data stored on the local filesystem, if your server dies or if an issue occurs. Hence, **making regular backups of all important data is very important**! Note that **this is your responsibility** - if there is an issue (even when this issue happens out of your control), you should have made sure that you have a pretty recent backup of your important data. Therefore, **we advise you to automatically configure and deploy a decent backup strategy** (e.g. with a daily backup).

In terms of where you could back up your data to, we have the following information for you:
- There is **no direct permanent storage available on the virtual machines**. This means that there is no disk available that will survive any machine crashes, resource expirations or reboot issues.
- The IDLab infrastructure offers **S3 object storage** that can be used for backups. This is not set up by default for your project; if you need it, ask your promotors to request a bucket. See the [Slices S3 object storage documentation](https://doc.slices-ri.eu/BasicServices/Storage/s3storage.html) for details.
- You are **free to connect to external cloud storage services for additional backups** if this better suits your requirements.

Note that the Slices CLI has basic scp support to transfer files from and to the machines. This is explained [here](https://doc.slices-ri.eu/BasicServices/BasicInfrastructure/first_machine.html#transferring-files-to-from-the-machine).

## Security management

Because the IDLab infrastructure is used for lots of experiments in a research context, **no default security is enabled on the servers**. Therefore, you will need to take security measures yourselves! It is **your responsibility to make sure that everything is sufficiently secure**.

Security issues do arise for servers on the IDLab infrastructure. For example, in the past, a server experienced an incident where a cryptocurrency miner was running as a process in a Jenkins Docker container, and it was using all CPU resources. The cause for this was the usage of weak credentials for the Jenkins users: an unauthorized user was able to log in to Jenkins and submit this job.

**Based on experience, we can give you the following tips to increase security. Please take them all into account!**
- **Strong passwords**: Do not use default or easy (or even no) passwords for services like Jenkins, SonarQube etc. Use strong passwords and disable access for anonymous users.
- **Firewall**: Make sure only the necessary ports are open to the outside world. You could for example use the Ubuntu default Uncomplicated Firewall (UFW). If you do this, do not forget to first allow SSH connections, otherwise you may lock yourself out of your server. In any case, there is lots of documentation available online about this topic. The following tutorial can be useful for this: https://www.digitalocean.com/community/tutorials/how-to-set-up-a-firewall-with-ufw-on-ubuntu.
- **HTTPS**: Setting up HTTPS to access your services is recommended. There are lots of options available to configure this, like for example Certbot (https://certbot.eff.org/), which has very easy tools for creating a trusted certificate, and configuring a web server like Apache or NGINX with it. It is most convenient to configure HTTPS on a domain name, which can be configured for you if you want (as explained [here](#receiving-a-ugent-domain-name)).

If you follow these tips, you should be covered for the most common security issues. The internet is your friend for any additional security hardening.

## Other important information & tips

### Keeping track of all installation commands

We have had some cases where servers could not be reached anymore and had to be started again on a new server node. Therefore, **we strongly advise you to create a shell script where you keep track of all commands you use for installing and configuring software etc. along the way**. If you ever end up with a dead server and need to reinstall everything from scratch, you can save a lot of time and will be happy that you have this script. **Make sure to save (or regularly back up) this script on some permanent storage.**

### Receiving a UGent domain name

If you want this, **a domain name can be configured for your public IPv4 address on the UGent domain**. This will be something like `[project_name].idlab.ugent.be`. Multiple domain names or working with subdomains is also possible.

To request this, contact your promotors with the following information for every requested domain:

```text
Name of project: ...
Name of experiment containing public server node: ...
Public IPv4 address: ...
Preferred domain name prefix: ...
```

For any special requests with multiple domain names or subdomains, be very specific in your request on what you want so it can be forwarded to the admins of the IDLab infrastructure.

If you want to configure a domain name outside the UGent domain yourself in another way, you are also free to do so.

### Communication between multiple servers

It may happen that you need to request new resources if the need arises (as mentioned before: only do so after requesting approval from your promotors). However, **there is only 1 public IPv4 address reserved for each project, so you are not allowed to reserve more than 1 server with a public IPv4 address** (unless you have a very good reason for this, but in that case always ask your promotors first). However, every server created on the VM infrastructure can reach any other server via their network interface linked to their public or private IPv4 address.
If you do notice that servers cannot communicate while you would expect this, let your promotors know.

## Troubleshooting

If you have any issues with the management of or access to your server resources or experiment, take a look in this section whether it contains some more input about the issue you are experiencing.
In general, please make sure to also follow the [general guidelines on troubleshooting and communication with your promotors](README.md#troubleshooting-and-communication-with-your-promotors).

### Root password required

If for some reason you need to have access to the root password, e.g. if you have made a syntax error in the /etc/sudoers file and you cannot sudo anymore, then you should contact your promotors. They will then contact the admins of the virtual wall, who can see the root password of your server. However, **please try to avoid this as much as possible** (in normal circumstances you do not need this password).

### Server cannot be accessed anymore

If you cannot access your server anymore, first check whether this is the case for all user accounts.
- If it is only for specific accounts, it will probably have to do with the SSH key configuration. Read the information about SSH keys carefully in the [section about accessing the server over SSH](#accessing-your-server-over-ssh), as well as the [instructions on how to register SSH keys for team members](account-project-setup.md#register-team-members-ssh-key-to-server).
- If it is the case for all accounts, there is a more severe issue with your server unfortunately. 
  - Try a reboot first of your server by following the [reboot instructions](#rebooting-a-server-resource). Try accessing it again after that. If this works, keep an eye on whether it happens again. If it keeps happening, it might be that there is something wrong with the software you have installed or configured. Let your promotors know in that case, so the IDLab admins can have a look at it. 
  - If rebooting doesn't help, check the [next section about a dead server](#dead-server).

### Dead server

If you cannot SSH into your server anymore using the [SSH accessing instructions](#accessing-your-server-over-ssh) on any account, there are mainly two options:
1. There is an issue with the Slices CLI or the IDLab infrastructure has caused your server to go in shutdown
2. Your server is dead and cannot be recovered.

Please contact your promotors so they can check with the admins which of both scenarios applies.

**If scenario (1) applies, the IDLab admins will be able to recover your server**. You will be informed when this has happened. If there is a clear reason on why this happened that can be avoided, you will be informed so you can take this into account.

**If the conclusion is that scenario (2) applies and that there is no way to recover your server, you will lose the current state of your server**. In that case, proceed as follows:
- Release the resources of your server using the instructions in [this section](#releasing-the-server-resources).
- Create a new server by following the steps in [this section](#reservation-of-server-resources). If you have kept an up-to-date installation script (as suggested [here](#keeping-track-of-all-installation-commands)) and backups of your important data (as suggested [here](#data-management-and-back-ups)), you should quickly be back on track.

In any case, if you start over again, please let your promotors know. **Never just start over again in this situation without contacting your promotors first to see whether there really is no way to recover the server**, to avoid you from doing unnecessary reconfiguration work.
