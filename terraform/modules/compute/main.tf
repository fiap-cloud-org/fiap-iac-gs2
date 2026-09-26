//SECURITY GROUP PUBLIC VPC10
resource "aws_security_group" "vpc_sg_pub1" {
    vpc_id = var.vpc10_id
    egress {
        from_port   = "0"
        to_port     = "0"
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = "0"
        to_port     = "0"
        protocol    = "-1"
        cidr_blocks = [var.vpc10_batata,var.vpc20_frita]
    }
    ingress {
        from_port   = "22"
        to_port     = "22"
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = "80"
        to_port     = "80"
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

//SECURITY GROUP PUBLIC VPC20

resource "aws_security_group" "vpc_sg_pub2" {
    vpc_id = var.vpc20_id
    egress {
        from_port   = "0"
        to_port     = "0"
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = "0"
        to_port     = "0"
        protocol    = "-1"
        cidr_blocks = [var.vpc10_batata,var.vpc20_frita]
    }
    ingress {
        from_port   = "22"
        to_port     = "22"
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = "80"
        to_port     = "80"
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

//SECURITY GROUP PRIVATE VPC10

resource "aws_security_group" "vpc_sg_priv1" {
    vpc_id = var.vpc10_id
    egress {
        from_port   = "0"
        to_port     = "0"
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = "0"
        to_port     = "0"
        protocol    = "-1"
        cidr_blocks = [var.vpc10_batata,var.vpc20_frita]
    } 
}

//SECURITY GROUP PRIVATE VPC20

resource "aws_security_group" "vpc_sg_priv2" {
    vpc_id = var.vpc20_id
    egress {
        from_port   = "0"
        to_port     = "0"
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = "0"
        to_port     = "0"
        protocol    = "-1"
        cidr_blocks = [var.vpc10_batata,var.vpc20_frita]
    } 
}


data "template_file" "nagios-core" {
  template = file("./modules/compute/scripts/nagios-core.sh")
  vars = {
    nagios_admin_password = var.nagios_admin_password
  }
}

//AQUI ESTA A MAQUINA NAGIOS CORE

resource "aws_instance" "nagios-core" {
  ami                    = "ami-0a1179631ec8933d7"
  instance_type          = "t2.micro"
  subnet_id              = var.vpc10_sn_pub_az1a_id
  vpc_security_group_ids = [aws_security_group.vpc_sg_pub1.id]
  key_name               = "vockey"
  user_data              = base64encode(data.template_file.nagios-core.rendered)
  tags = {
    Name = "nagios-core"
  }
}

data "template_file" "nagios-agent" {
  template = file("./modules/compute/scripts/nagios-agent.sh")
}

//MAQUINA NAGIOS AGENT (noce_c) que esta na VPC10 e na subnet privada az1c com o security group privado1

resource "aws_instance" "node_c" {
  ami                    = "ami-0a1179631ec8933d7"
  instance_type          = "t2.micro"
  subnet_id              = var.vpc10_sn_priv_az1c_id
  vpc_security_group_ids = [aws_security_group.vpc_sg_priv1.id]
  key_name               = "vockey"
  user_data              = base64encode(data.template_file.nagios-agent.rendered)
  tags = {
    Name = "agent-node-c"
  }
}

//MAQUINA NAGIOS AGENT (node_a) que esta na VPC10 e na subnet publica az1a com o security group publico1

resource "aws_instance" "node_a" {
  ami                    = "ami-0a1179631ec8933d7"
  instance_type          = "t2.micro"
  subnet_id              = var.vpc10_sn_pub_az1a_id
  vpc_security_group_ids = [aws_security_group.vpc_sg_pub1.id]
  key_name               = "vockey"
  user_data              = base64encode(data.template_file.nagios-agent.rendered)
  tags = {
    Name = "agent-node-a"
  }
}

//MAQUINA NAGIOS AGENT (noce_d) que esta na VPC10 e na subnet privada az1c com o security group privado1

resource "aws_instance" "node_d" {
  ami                    = "ami-0a1179631ec8933d7"
  instance_type          = "t2.micro"
  subnet_id              = var.vpc10_sn_priv_az1c_id
  vpc_security_group_ids = [aws_security_group.vpc_sg_priv1.id]
  key_name               = "vockey"
  user_data              = base64encode(data.template_file.nagios-agent.rendered)
  tags = {
    Name = "agent-node-d"
  }
}

//MAQUINA NAGIOS AGENT (node_b) que esta na VPC20 e na subnet publica az1a com o security group publico2

resource "aws_instance" "node_b" {
  ami                    = "ami-0a1179631ec8933d7"
  instance_type          = "t2.micro"
  subnet_id              = var.vpc20_sn_pub_az1a_id
  vpc_security_group_ids = [aws_security_group.vpc_sg_pub2.id]
  key_name               = "vockey"
  user_data              = base64encode(data.template_file.nagios-agent.rendered)
  tags = {
    Name = "agent-node-b"
  }
}

//MAQUINA NAGIOS AGENT (node_wim) que esta na VPC20 e na subnet publica az1a com o security group publico2

resource "aws_instance" "node_wim" {
  ami                    = "ami-0a1179631ec8933d7"
  instance_type          = "t2.micro"
  subnet_id              = var.vpc20_sn_pub_az1a_id
  vpc_security_group_ids = [aws_security_group.vpc_sg_pub2.id]
  key_name               = "vockey"
  user_data              = base64encode(data.template_file.nagios-agent.rendered)
  tags = {
    Name = "agent-node-wim"
  }
}

//MAQUINA NAGIOS AGENT (node_e) que esta na VPC20 e na subnet privada az1c com o security group privado2

resource "aws_instance" "node_e" {
  ami                    = "ami-0a1179631ec8933d7"
  instance_type          = "t2.micro"
  subnet_id              = var.vpc20_sn_priv_az1c_id
  vpc_security_group_ids = [aws_security_group.vpc_sg_priv2.id]
  key_name               = "vockey"
  user_data              = base64encode(data.template_file.nagios-agent.rendered)
  tags = {
    Name = "agent-node-e"
  }
}

//MAQUINA NAGIOS AGENT (node_f) que esta na VPC20 e na subnet privada az1c com o security group privado2

resource "aws_instance" "node_f" {
  ami                    = "ami-0a1179631ec8933d7"
  instance_type          = "t2.micro"
  subnet_id              = var.vpc20_sn_priv_az1c_id
  vpc_security_group_ids = [aws_security_group.vpc_sg_priv2.id]
  key_name               = "vockey"
  user_data              = base64encode(data.template_file.nagios-agent.rendered)
  tags = {
    Name = "agent-node-f"
  }
}