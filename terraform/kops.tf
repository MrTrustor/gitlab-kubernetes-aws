################################################################################
# The MIT License (MIT)
# Copyright (c) 2016 <Oxalide, Théo Chamley>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
################################################################################

variable "node_sg_id" {
  # TO_CHANGE: The security group ID for your worker nodes
  default = "sg-xxxxxx"
}

variable "master_sg_id" {
  # TO_CHANGE: The security group ID for your master nodes
  default = "sg-xxxxxx"
}

# Resource managed by KOPS DO NOT TOUCH
resource "aws_vpc" "kops_vpc" {
  # TO_CHANGE: CIDR of your VPC + right tags
  cidr_block = "10.0.0.0/22"
  tags {
    Name = "k8s.myzone.net"
    KubernetesCluster = "k8s.myzone.net"
  }
}

# Resource managed by KOPS DO NOT TOUCH
resource "aws_subnet" "kops_suba" {
  vpc_id = "${aws_vpc.kops_vpc.id}"
  # TO_CHANGE: CIDR of your subnet in AZ a + right tags
  cidr_block = "10.0.0.128/25"
  tags {
    Name = "eu-west-1a.k8s.myzone.net"
    KubernetesCluster = "k8s.myzone.net"
  }
}
# Resource managed by KOPS DO NOT TOUCH
resource "aws_subnet" "kops_subb" {
  vpc_id = "${aws_vpc.kops_vpc.id}"
  # TO_CHANGE: CIDR of your subnet in AZ b + right tags
  cidr_block = "10.0.1.0/25"
  tags {
    Name = "eu-west-1b.k8s.myzone.net"
    KubernetesCluster = "k8s.myzone.net"
  }
}
# Resource managed by KOPS DO NOT TOUCH
resource "aws_subnet" "kops_subc" {
  vpc_id = "${aws_vpc.kops_vpc.id}"
  # TO_CHANGE: CIDR of your subnet in AZ c + right tags
  cidr_block = "10.0.1.128/25"
  tags {
    Name = "eu-west-1c.k8s.myzone.net"
    KubernetesCluster = "k8s.myzone.net"
  }
}
