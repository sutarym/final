provider "aws" {
  region = "ap-south-1"
   access_key = "AKIAXQM6UOUEOIAQPH2C"
  secret_key = "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"
}

resource "aws_vpc" "mainVPC" {
  cidr_block       = "10.0.0.0/16"
 

  tags = {
    Name = "mainVPC"
  }
}

resource "aws_subnet" "Public_Subnet" {
  vpc_id     = aws_vpc.mainVPC.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Public_Subnet"
  }
}

resource "aws_subnet" "Private_Subnet" {
  vpc_id     = aws_vpc.mainVPC.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "Private_Subnet"
  }
}
output "subnet_id" {
  value = aws_subnet.Private_Subnet.id
}

resource "aws_nat_gateway" "NAT_gw" {
  allocation_id = aws_eip.EIP.id
  subnet_id     = aws_subnet.Public_Subnet.id

  tags = {
    Name = "NAT_gw"
  }
}

resource "aws_eip" "EIP" {
  vpc      = true
}


resource "aws_route_table" "Private_Route_Table" {
  vpc_id = aws_vpc.mainVPC.id

  tags = {
    Name = "Private_Route_Table"
  }
}

resource "aws_route" "nat_gateway_route" {
  route_table_id         = aws_route_table.Private_Route_Table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.NAT_gw.id

  #replace = true
  depends_on = [aws_nat_gateway.NAT_gw]
}

# resource "aws_main_route_table_association" "Private_Route_Table_with_Private_Subnet" {
#   vpc_id         = aws_vpc.mainVPC.id
#   route_table_id = aws_route_table.Private_Route_Table.id
# }

  resource "aws_route_table_association" "privateRT_with_private" {
  subnet_id      = aws_subnet.Private_Subnet.id
  route_table_id = aws_route_table.Private_Route_Table.id
}


resource "aws_security_group" "SG" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.mainVPC.id

  ingress {
    
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  tags = {
    Name = "SG"
  }
}


resource "aws_iam_role" "test_role" {
  name = "test_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "test_role1"
  }
}

resource "aws_iam_role_policy" "test_policy" {
  name = "test_policy"
  role = aws_iam_role.test_role.id


  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
          "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.test_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}


resource "aws_lambda_function" "lambda" {

  filename      = "lambda.zip"
  function_name = "lambda"
  role          = aws_iam_role.test_role.arn
  handler       = "lambda.lambda_handler"
  timeout = 180

 # source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.7"

  
}

resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.mainVPC.id
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.mainVPC.id

  tags = {
    Name = "Public_Route_Table"
  }
}

resource "aws_route" "internet_gateway_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.example.id
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment_for_vpc" {
  role       = aws_iam_role.test_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
}

  resource "aws_route_table_association" "PublicRT_with_public" {
  subnet_id      = aws_subnet.Public_Subnet.id
  route_table_id = aws_route_table.public_route_table.id
}
