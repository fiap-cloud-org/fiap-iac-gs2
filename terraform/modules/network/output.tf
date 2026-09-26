output "vpc10_id" {
    value = "${aws_vpc.vpc10.id}"
}

output "vpc20_id" {
    value = "${aws_vpc.vpc20.id}"  
}

output "sn_pub_az1a_vpc10_id" {
    value = "${aws_subnet.sn_pub_az1a_vpc10.id}"  
}

output "sn_pub_az1a_vpc20_id" {
    value = "${aws_subnet.sn_pub_az1a_vpc20.id}"  
}

output "sn_priv_az1c_vpc10_id" {
    value = "${aws_subnet.sn_priv_az1c_vpc10.id}"  
}

output "sn_priv_az1c_vpc20_id" {
    value = "${aws_subnet.sn_priv_az1c_vpc20.id}"  
}
