# VPC
resource "aws_vpc" "this" {
  cidr_block           = "10.100.0.0/16"
  tags = { Name = "${local.name}-vpc" }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = { Name = "${local.name}-igw" }
}

# Subnet Keycloak
resource "aws_subnet" "keycloak" {
  count = 2

  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.100.${count.index}.0/24"
  availability_zone = data.aws_availability_zones.azs.names[count.index]

  tags = { Name = "${local.name}-keycloak-subnet-${count.index}" }
}

resource "aws_route_table" "keycloak" {
  vpc_id = aws_vpc.this.id
  tags = { Name = "${local.name}-keycloak-rt" }
}

resource "aws_route_table_association" "keycloak" {
  count = 2

  subnet_id      = aws_subnet.keycloak[count.index].id
  route_table_id = aws_route_table.keycloak.id
}

resource "aws_route" "keycloak_internet" {
  route_table_id         = aws_route_table.keycloak.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

# Subnet application
resource "aws_subnet" "application" {
  count = 2

  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.100.${count.index + 2}.0/24"
  availability_zone = data.aws_availability_zones.azs.names[count.index]

  tags = { Name = "${local.name}-application-subnet-${count.index}" }
}

resource "aws_route_table" "application" {
  vpc_id = aws_vpc.this.id
  tags = { Name = "${local.name}-application-rt" }
}

resource "aws_route_table_association" "application" {
  count = 2

  subnet_id      = aws_subnet.application[count.index].id
  route_table_id = aws_route_table.application.id
}

