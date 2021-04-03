provider "aws" {
    region="ap-south-1"
}

#Ec2 creation
resource "aws_instance" "myec2" {
    ami="ami-0bcf5425cdc1d8a85"
    instance_type="t2.micro"
    key_name=aws_key_pair.keypair.key_name
    vpc_security_group_ids=[aws_security_group.allow_ports.id]
    user_data=<<-EOF
                 #!/bin/bash
                 yum install httpd -y
                 echo "hey i am $(hostname -f)" > /var/www/html/index.html
                 service httpd start
                 chkconfig httpd on
                 EOF

    tags = {
        Name="Sample"
    }
}

#creating key pair
resource "aws_key_pair" "keypair" {
    key_name="terraformkey"
    public_key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQClkALPP7RhijJUf1W501LDhzHUKwT8NgcxawPEQ9HCyanY8klnrRyCFTgUUtKo1bB8rI5tVaNso1hg7h11Fw5JGGydynuwUnb6C0/BPfYNxH0W82rq2TmoQLpq3jpR/kGgTPgL3yhhiVOCwxr768GMgH5ha3u76BgDSiXWFgyHS/PQuaeP1/cOLFkh6hyf6K18ER2AFVbJ7jXwedBj5vta1fiJCA2N8wDiaW7tpp7TQUJbwNO6Lj6+aGRs5SSjGTbUI5RTJJ4i2hMw67Ro9gLJyHXu0GkO0gG6mbKYExxv4wqSn6ZC2x8ymmVDNeoE3n4evJu/cuUzUn7wM4klBy8t lenovo@Krishnaarjun"
}

#creating elastic IP
resource "aws_eip" "myeip"{
    vpc="true"
    instance=aws_instance.myec2.id
}

#get default vpc
resource "aws_default_vpc" "default" {
    tags={
        Name="Default vpc"
    }
}

resource "aws_security_group" "allow_ports"{
    name="allow_ports"
    description="Allow inbound traffic"
    vpc_id=aws_default_vpc.default.id
    ingress{
        description="http from vpc"
        from_port=80
        to_port=80
        protocol="tcp"
        cidr_blocks=["0.0.0.0/0"]
    }
    ingress{
        description="tomcat port from vpc"
        from_port=8080
        to_port=8080
        protocol="tcp"
        cidr_blocks=["0.0.0.0/0"]
    }
    ingress{
        description="TLS from vpc"
        from_port=443
        to_port=443
        protocol="tcp"
        cidr_blocks=["0.0.0.0/0"]
    }
    egress{
        description="outbound from vpc"
        from_port=0
        to_port=0
        protocol="-1"
        cidr_blocks=["0.0.0.0/0"]
    }

    tags ={
        Name="myterraformSG"
    }

}