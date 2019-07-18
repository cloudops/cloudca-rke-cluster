# Overview

This terraform configuration is used to build a RKE cluster on [cloud.ca](https://cloud.ca/) infrastructure.

## Table of Content

- [Resources](#resources)
- [Requirements](#requirements)
- [Available Kubernetes Versions](#available-kubernetes-versions)
- [Required Inputs](#required-inputs)
- [Optional Inputs](#optional-inputs)
- [Outputs](#outputs)
- [Usage](#usage)
- [License](#license)

## Resources

It will create the required infrastructure:

- one or several k8s master node(s)
- two or several k8s worker nodes

## Requirements

- [Terraform](https://www.terraform.io/downloads.html) 0.12+
- [Terraform Provider for cloud.ca](https://github.com/cloud-ca/terraform-provider-cloudca) 1.5+
- [Terraform Provider for RKE](https://github.com/yamamoto-febc/terraform-provider-rke) 0.12+
- [terraform-docs](https://github.com/segmentio/terraform-docs) 0.5+
<!-- terraform-docs starts -->

## Available Kubernetes Versions

Version of Kubernetes to be used in the RKE cluster can be controlled with [kubernetes_version](#kubernetes_version), which depends on the version of terraform-provider-rke being used in which depends on the version of RKE binary beind used in that provider version.

To get the list of available (and the default) version of Kubernetes take a look at release notes of [terraform-provider-rke](https://github.com/yamamoto-febc/terraform-provider-rke/releases) and [RKE](https://github.com/rancher/rke/releases) respectively.

## Required Inputs

The following input variables are required:

### api\_key

Description: cloud.ca API key to use

Type: `string`

### environment\_id

Description: The environment ID to create resources in

Type: `string`

### network\_id

Description: The network ID to create resources in

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### kubernetes\_version

Description: Kubernetes version to install in the cluster

Type: `string`

Default: `"v1.14.3-rancher1-1"`

### master\_count

Description: Number of master node(s) to create

Type: `string`

Default: `"1"`

### node\_prefix

Description: Prefix to be used in name of instances, e.g. `cca` in `cca-foo-service01`

Type: `string`

Default: `"cca"`

### node\_service

Description: Service to be used in name of instances, e.g. `service` in `cca-foo-service01`

Type: `string`

Default: `"rke"`

### node\_type

Description: Type to be used in name of instances, e.g. `foo` in `cca-foo-service01`

Type: `string`

Default: `"cluster"`

### node\_username

Description: The username to create in the nodes with SSH access

Type: `string`

Default: `"rke"`

### worker\_count

Description: Number of worker node(s) to create

Type: `string`

Default: `"2"`

## Outputs

The following outputs are exported:

### master\_ips

Description: List of private IP of master node(s)

### worker\_ips

Description: List of private IP of worker node(s)

<!-- terraform-docs ends -->

## Usage

1. Clone the repository into an appropriate name:

    ```bash
    git clone https://github.com/khos2ow/cloudca-rke-cluster.git cloudca-rke-cluster
    ```

2. Create `terraform.tfvars` containing:

    ```toml
    api_key = "<cloud_ca_API_KEY>"
    ```

3. Execute the following command to initialize the repository:

    ```bash
    make init plan
    ```

## License

```text
MIT License

Copyright (c) 2019 Khosrow Moossavi

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
