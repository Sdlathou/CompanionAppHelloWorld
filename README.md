# System administration for IDLab server infrastructure

This repository contains all necessary information to use the IDLab server infrastructure for your thesis project.

***Disclaimer**: this infrastructure is relatively new, which means that this repository may still contain errors or be incomplete. If you notice anything wrong or missing, please let your promotors know so this guide can be updated.*

This page contains some general information to take into account during the usage of IDLab infrastructure, an introduction to the Slices CLI and how to create an experiment, and an overview of the available guides in this repository.

## General information

Please read this information carefully, and keep it into account throughout your thesis.

### Available infrastructure and documentation

We are using the Slices platform. A lot of documentation about this platform is available on https://doc.slices-ri.eu/index.html. If you cannot find the information you need in this repository, always take a look at this documentation first.

#### Services that can be used

As you can see on the documentation homepage, multiple services are offered by the Slices platform. For your thesis, you will most likely only need the **basic infrastructure service** (virtual machines with a public IPv4). The following services are available to you if needed:
- **Basic infrastructure service** (only virtual machines, no bare metal servers unless explicit permission) — this is the main service you will use.
- **S3 object storage** — can be useful for backups of your VM data. This is not set up by default; if you need it, ask your promotors to request a bucket for your project. See the [Slices S3 object storage documentation](https://doc.slices-ri.eu/BasicServices/Storage/s3storage.html) for details.
- **Machine learning: JupyterHub and GPULab** — only if you need offline GPU access (e.g. model training). See the [JupyterHub docs](https://doc.slices-ri.eu/BasicServices/MachineLearning/jupyter/index.html) and [GPULab docs](https://doc.ilabt.imec.be/ilabt/gpulab/index.html). If you want to use these, inform your promotors first.

Any other service (e.g. the Blueprint services) listed cannot be used without requesting explicit permission from your promotors.
If you are unsure about whether you can use something, ask your promotors first.

#### Important terminology

It is important to be familiar with the terminology used by the Slices CLI. Below you can find the most important terms you need to know from the start:

- **Project**: You have received exactly 1 project on the infrastructure. This project is used for all services. Your project is called `thesis-senne2026`.
- **Experiment**: An experiment is a group of requested resources. It is created inside a project and has a certain duration. At the end of this duration, the resources in this experiment are released and unrecoverable. You will normally only work within 1 experiment.
- **Site**: Resources on the "Basic infrastructure service" are available on so-called "sites". Unless you receive an exception, you should always work on the VM (virtual machine) site.

### Troubleshooting and communication with your promotors

If you have any questions or issues related to the usage of the IDLab infrastructure, reach out to your promotors.

If the question or issue you have is specifically related to the infrastructure, you have the possibility to email [helpdesk@ilabt.imec.be](mailto:helpdesk@ilabt.imec.be). Make sure to only do so after you have checked with your promotors whether this is fine. In any case where you *would* be in contact with them (or another support email address) via email, **always** put your promotors in cc.

If the problem you are experiencing is specifically related to the Slices CLI, always ensure first (before contacting anyone) that you are working on the latest version through:
```shell
pip install --upgrade slices-cli --extra-index-url=https://doc.slices-ri.eu/pypi/
```

### Encountering bugs

You might encounter any of the following during your work: wrong information in this repository, important information missing in this repository, or even bugs in the infrastructure itself (e.g. with the Slices CLI). In all cases, we ask you to let your promotors know.

### Fair use of resources

Do not use more resources than you have been told that you are allowed to use. If you use services like GPULab or JupyterHub, a fair use policy is defined in their documentation — **follow it at all times**. Take the following into account:
- If for some reason you need more resources than what you have been told, always inform your promotors about this and explain what you would need more and a motivation why.
- If at some point you receive an email from someone working in IDLab about the amount of resources you are using on one of the services, please **always inform your promotors about this**.

## Slices CLI

To make use of some of the services offered on the Slices platform, you need to use the Slices CLI.

### Installation instructions

Follow the [instructions on the Slices documentation to install the Slices CLI](https://doc.slices-ri.eu/SupportingServices/slicescli.html#install-slices-cli).
In short, it boils down to installing a fresh Python venv (preferably), and then executing the commands in the [`install-and-setup-slices.sh`](install-and-setup-slices.sh) script. You can directly run this script from a new Python venv, after you have changed the parameters at the top.

Note that the [SSH key registration](https://doc.slices-ri.eu/SupportingServices/slicescli.html#registering-your-public-ssh-key) should only done once per public SSH key on your account.
If you perform this request twice for the same SSH key (e.g. on multiple Python virtual environments on the same device), the last command in the [`install-and-setup-slices.sh`](install-and-setup-slices.sh) script will fail.

### Create an experiment

Before you start using any of the services of the Slices platform, you should have created an experiment through the Slices CLI. For this, you can use the [`create-experiment.sh`](create-experiment.sh) script. Before running it, make sure to update the parameters at the top. Make sure you source the script by running `source create-experiment.sh`, as the script sets some environment variables used by the Slices CLI in your shell:
- `SLICES_EXPERIMENT` to have other commands automatically work within the created experiment
- `SLICES_BI_SITE_ID` to ensure you only work within the VM site
In the guides within this repository, we will assume you have correctly set these environment variables in the shell with the Slices CLI installed.

By following the script to create an experiment, it is automatically shared with all project members, including your promotors. If for some reason you create your experiment without making use of the [`create-experiment.sh`](create-experiment.sh) script, **make sure that it is always shared with your promotors**. This is required for the IDLab admins to know that the resources you are using are approved. The essential command to do so is given below. This will work since your promotors are already part of your project.

```shell
slices experiment member add <experiment> --all-project-members
```

## Overview of repository

Different information is present in different Markdown files in this repository. This section gives an overview of the available guides:

- [Account and project set-up on Slices platform](account-project-setup.md) (general set-up of accounts and projects)
- [Usage of the basic infrastructure service with the Slices CLI](basic-infrastructure-service.md) (guide for reserving, managing and using VM server nodes — this is the main guide you will need)
- [RUNBOOK](RUNBOOK.md) — how to deploy the Hello World full-stack app (frontend + backend) onto the provisioned VM

## Deploying the Hello World app

After provisioning a VM with [`setup-server.sh`](setup-server.sh), run the following command from your local machine to deploy the app:

```shell
ssh ubuntu@<VM_IP> 'bash -s' < deploy-app.sh
```

This clones the repository on the VM, registers a systemd service, and opens port 8080. The app is then reachable at `http://<VM_IP>:8080/`. See [RUNBOOK.md](RUNBOOK.md) for the full step-by-step flow and verification commands.
