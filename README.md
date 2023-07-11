# terraform-ansible-packer-resource

Terraform Example: using the Toowoxx Packer Terraform Resource with Ansible and EC2

## About

This example uses Terraform, Packer and Ansible to provision a AMI using Packer with software that is installed using Ansible and then Terraform picking up the AMI using a datasource.

## Workflow

The steps it takes to visualise a workflow:

1. Packer provisions a temporary instance and uses ansible-local to deploy the ansible playbook (uses amazon linux as a base).
2. Once the step is completed Packer builds a AMI in the naming convention `project-name-dockernodes-2023071200`
3. Terraform does a data source lookup for a AMI based on the prefix `project-name-dockernodes-*` and uses the latest published AMI
4. The EC2 instance gets provisioned off that AMI
5. If the packer definition or ansible tasks file gets updated, packer will build a new AMI

## Note

I am using the [toowoxx/packer](https://registry.terraform.io/providers/toowoxx/packer/latest/docs) terraform provider, which is terraform calling packer. Note that, although this suites my testing use-cases, this might not always be the best way to provision your AMIs.

Another workflow might be to split your terraform deploys and AMI provisioning with packer in two different steps, eg:

1. Have a build pipeline that runs packer to build and provision AMIs.
2. Have a deploy pipeline that looks up the provisioned AMI and deploy your EC2 instance.

## Whats included in the Ansible Playbook

The ansible playbook will deploy the following software:

1. Docker
2. Docker Compose

And it will add the `ec2-user` to the `docker` group and also adjust the permissions to run `docker` as the `ec2-user`.

## Usage

I am using a aws configured profile named `test` which is defined in:

1. `environments/dev/providers.tf`
2. `packer/image.pkr.hcl`

The region that I'm using is `eu-west-1` which is defined in `environments/dev/variables.tf`.

Once you have defined your aws profiles, you can initialize terraform to download the providers:

```bash
cd environments/dev
terraform init
```

Run a plan:

```bash
terraform plan
```

Then deploy your infrastructure:

```bash
terraform apply
```

What this will do is the following:

1. Uses packer to spin up a temporary EC2 instance and uses the ansible provisioner to install the software defined by the ansible playbook
2. Builds the AMI and publishes it to AWS with a defined naming pattern
3. Terraform will deploy a EC2 instance from the published AMI.
4. It uses your `~/.ssh/id_rsa.pub` key for a keypair to SSH

If you want to update the software to deploy a new AMI and a EC2 instance from that AMI, you can edit any of the following files:

1. `ansible/docker-node/tasks/setup-instance.yml`
2. `packer/image.pkr.hcl`

To remove the infrastructure:

```bash
terraform destroy
```

Note that the AMI's don't get removed as you will need to manually remove them.

## Project Structure

The following outlines the project structure:

```bash
├── README.md
├── ansible
│   ├── docker-node
│   │   ├── defaults
│   │   │   └── main.yml
│   │   ├── tasks
│   │   │   ├── main.yml
│   │   │   └── setup-instance.yml
│   │   └── vars
│   │       └── main.yml
│   ├── inventory
│   │   └── default.yml
│   └── playbook.yml
├── environments
│   └── dev
│       ├── main.tf
│       ├── outputs.tf
│       ├── providers.tf
│       └── variables.tf
└── packer
    └── image.pkr.hcl

9 directories, 12 files
```

## Resources

The following providers were used:

- [toowoxx/packer](https://registry.terraform.io/providers/toowoxx/packer/latest/docs)
- [hashicorp/aws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
