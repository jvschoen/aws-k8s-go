# Fetch the list of available availability zones in the selected region
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "eks_vpc" {
    cidr_block = "10.0.0.0/16"

    tags = {
        Name = "eks-vpc"
    }
}

resource "aws_subnet" "eks_subnet" {
    count = 2

    vpc_id            = aws_vpc.eks_vpc.id
    cidr_block        = cidrsubnet(aws_vpc.eks_vpc.cidr_block, 8, count.index)
    availability_zone = element(data.aws_availability_zones.available.names, count.index)

    tags = {
        Name = "eks-subnet-${count.index}"
    }
}

resource "aws_internet_gateway" "eks_igw" {
    vpc_id = aws_vpc.eks_vpc.id

    tags = {
        Name = "eks-igw"
    }
}

resource "aws_route_table" "eks_route_table" {
    vpc_id = aws_vpc.eks_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.eks_igw.id
    }

    tags = {
        Name = "eks-route-table"
    }
}

resource "aws_route_table_association" "eks_route_table_association" {
    count          = length(aws_subnet.eks_subnet)
    subnet_id      = aws_subnet.eks_subnet[count.index].id
    route_table_id = aws_route_table.eks_route_table.id
}