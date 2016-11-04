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

resource "aws_efs_file_system" "gitlab_nfs" {
  tags {
    Name = "k8s.myzone.net"
    KubernetesCluster = "k8s.myzone.net"
  }
}

resource "aws_security_group" "EFS_K8s" {
  name = "EFS_K8s"
  description = "Allow NFS inbound traffic"
  vpc_id = "${aws_vpc.kops_vpc.id}"
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    security_groups =  ["${var.node_sg_id}", "${var.master_sg_id}"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "EFS_K8s"
    KubernetesCluster = "k8s.myzone.net"
  }
}

resource "aws_efs_mount_target" "gitlab_nfsa" {
  file_system_id = "${aws_efs_file_system.gitlab_nfs.id}"
  subnet_id = "${aws_subnet.kops_suba.id}"
  security_groups = ["${aws_security_group.EFS_K8s.id}"]
}
resource "aws_efs_mount_target" "gitlab_nfsb" {
  file_system_id = "${aws_efs_file_system.gitlab_nfs.id}"
  subnet_id = "${aws_subnet.kops_subb.id}"
  security_groups = ["${aws_security_group.EFS_K8s.id}"]
}
resource "aws_efs_mount_target" "gitlab_nfsc" {
  file_system_id = "${aws_efs_file_system.gitlab_nfs.id}"
  subnet_id = "${aws_subnet.kops_subc.id}"
  security_groups = ["${aws_security_group.EFS_K8s.id}"]
}

output "NFS_mount_points" {
  value = "${aws_efs_mount_target.gitlab_nfsa.dns_name} ${aws_efs_mount_target.gitlab_nfsb.dns_name} ${aws_efs_mount_target.gitlab_nfsc.dns_name}"
}

resource "aws_db_subnet_group" "gitlab_pgsql" {
  name = "gitlab_pgsql"
  subnet_ids = ["${aws_subnet.kops_suba.id}", "${aws_subnet.kops_subb.id}", "${aws_subnet.kops_subc.id}"]
  tags {
    Name = "Gitlab PgSQL"
    KubernetesCluster = "k8s.myzone.net"
  }
}

resource "aws_security_group" "gitlab-pgsql" {
  name = "gitlab-pgsql"
  description = "Allow PgSQL inbound traffic"
  vpc_id = "${aws_vpc.kops_vpc.id}"
  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "TCP"
    security_groups =  ["${var.node_sg_id}", "${var.master_sg_id}"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "gitlab-pgsql"
    KubernetesCluster = "k8s.myzone.net"
  }
}

resource "aws_db_instance" "gitlab-pgsql" {
  allocated_storage       = "50"
  engine                  = "postgres"
  engine_version          = "9.3.14"
  identifier              = "gitlab-pgsql"
  instance_class          = "db.t2.medium"
  storage_type            = "gp2"
  name                    = "gitlab_production"
  # TO_CHANGE: PostgreSQL password
  password                = "changeme"
  username                = "gitlab"
  backup_retention_period = "30"
  backup_window           = "04:00-04:30"
  maintenance_window      = "sun:04:30-sun:05:30"
  multi_az                = true
  port                    = "5432"
  vpc_security_group_ids  = ["${aws_security_group.gitlab-pgsql.id}"]
  db_subnet_group_name    = "${aws_db_subnet_group.gitlab_pgsql.name}"
  storage_encrypted       = false
  auto_minor_version_upgrade = true

  tags {
    Name        = "gitlab-pgsql"
    KubernetesCluster = "k8s.myzone.net"
  }
}

output "PgSQL_endpoint" {
  value = "${aws_db_instance.gitlab-pgsql.endpoint}"
}
