resource "aws_ecr_repository" "emart_client" {
  name                 = "emart/client"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "emart_nodeapi" {
  name                 = "emart/nodeapi"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "emart_javaapi" {
  name                 = "emart/javaapi"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "emart_policy" {
  for_each = {
    client   = aws_ecr_repository.emart_client.name
    nodeapi  = aws_ecr_repository.emart_nodeapi.name
    javaapi  = aws_ecr_repository.emart_javaapi.name
  }

  repository = each.value

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
