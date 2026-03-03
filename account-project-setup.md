# Account and project set-up

This guide explains how to set up your account and project on the IDLab portal built on top of the Slices platform. This portal is accessible via https://account.ilabt.imec.be/.

## Join the project

The following step-by-step guide explains how to log in to the portal and join your project. This should only be done once.

1. Go to https://account.ilabt.imec.be/. 
2. Click 'Login'. 
3. Click on 'Ghent University' below 'I have an academic account'. 
4. Provide your UGent credentials and log in. 
5. You will now reach the main dashboard of the portal. In this dashboard, click 'Request to join a project'. 
6. Provide the name of your project, which has already been created for you. The project name is `thesis-senne2026`. Click 'Request to join'.

Wait until your request is approved. You are then a member of the project. Your promotors will make you administrator of this project, so that you can approve other team members to be added to the project as well.

## Give other team members access to services

If you want multiple people to have access to the different available services, they will need to be added to the project and possibly the different experiments. The list below details which steps below should be followed to allow a team member to use different services. The steps refer to the different subsections below.

- Use the basic infrastructure service:
  - Manage experiments or reserve new resources: let team member install Slices CLI, let team member join project, add team member to experiment
  - Only log in to server: register team member's SSH key to server
- Use JupyterHub for Machine Learning: let team member join project, add team member to experiment
- Use GPULab: let team member join project, add team member to experiment

### Let team member install Slices CLI

Refer the team member to the installation guide of the Slices CLI.

### Let team member join project

**Task of the team member:**
1. Go to https://account.ilabt.imec.be/. 
2. Click 'Login'. 
3. Click on 'Ghent University' below 'I have an academic account'. 
4. Provide your UGent credentials and log in. 
5. You will now reach the main dashboard of the portal. In this dashboard, click 'Request to join a project'. 
6. Provide the name of your project: `thesis-senne2026`. Click 'Request to join'.
7. Wait until a project admin has approved your request so you are added to the project.

**Task of the project admin: approving the project join requests.**
This can be done through the portal at https://account.ilabt.imec.be/. Every admin will also receive an email upon every join request, allowing them to open the webpage for approval there. Make sure to approve as member if you want the team member to collaborate. Every regular project member can add experiments and add or delete resources to experiments, so this role is sufficient for others.

### Add team member to experiment

A project admin can add project members to existing experiments. On the Slices CLI, this can be done with the following command:

```shell
slices experiment member add <experiment> <username>
```

Replace `<experiment>` by the experiment name, and `<username>` by the person's username. You can find the exact username of the team members via https://account.ilabt.imec.be. This is usually your UGent username, but not always.

Alternatively, you can add all project members to an experiment with the following command:
```shell
slices experiment member add <experiment> --all-project-members
```

To list the members of an experiment at any time, use:

```shell
export SLICES_EXPERIMENT=<experiment>
slices experiment member list -s email
```

Note that you have to set the `SLICES_EXPERIMENT` environment variable first, as you cannot choose in the 2nd command for which experiment you want to list the members. There is a bug as well in the command requiring you to explicitly state the sort parameter via `-s email`, as the default value is considered invalid.

Note as well that all resources within an experiment are shared with all experiment members. It thus suffices to only add every person once to the experiment.

### Register team member's SSH key to server

If you only want to give a team member access to a server node, without this person needing to manage the experiments or use other services, then it suffices to just give the team member SSH access to the server. For this, the team member should not be part of the project or experiment.

Giving a team member access can be done by adding this person's public SSH key to the `~/.ssh/authorized_keys` file. Just copy the content of the public key file, which is usually in `~/.ssh/id_ed25519.pub` or `~/.ssh/id_rsa.pub`, to a new line in this server file.
