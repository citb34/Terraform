resource "aws_instance" "web" {
    count                   = 2
    ami                     = "${var.AMI_ID}"
    instance_type           = "${var.INSTANCE_TYPE}"
    key_name                = "devops"
    subnet_id               = "${element(var.PUBLIC_SUBNETS, count.index)}"
    vpc_security_group_ids  = ["${aws_security_group.ec2-sg.id}"]
    tags                    = {
        Name            = "${var.PROJECT_NAME}-${var.ENV}-Instance-${count.index+1}"
        Project-ENV     = "${var.ENV}"
        Project-NAME    = "${var.PROJECT_NAME}"
        Created-By      = "Terraform"
  }
}

resource "null_resource" "ec2-webapp-setup" {

  provisioner "remote-exec" {
    connection {
        type     = "ssh"
        host     = "${element(aws_instance.web.*.private_ip, count.index)}"
        user     = "centos"
        private_key = "${file("/home/centos/devops.pem")}"
    }
    inline = [
            "sudo yum install ansible -y"
            ]
    }
}