{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Expire images older than 7 days",
      "selection": {
        "tagStatus": "untagged",
        "countType": "sinceImagePushed",
        "countUnit": "days",
        "countNumber": 7
      },
      "action": {
        "type": "expire"
      }
    },
    {
      "rulePriority": 2,
      "description": "Keep images matching intg, staging or prod prefixes",
      "selection": {
        "tagStatus": "tagged",
        "tagPrefixList": [
          "intg",
          "staging",
          "prod"
        ],
        "countType": "imageCountMoreThan",
        "countNumber": 9999
      },
      "action": {
        "type": "expire"
      }
    },
    {
      "rulePriority": 3,
      "description": "Remove anything else older than 7 days",
      "selection": {
        "tagStatus": "any",
        "countType": "sinceImagePushed",
        "countUnit": "days",
        "countNumber": 7
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
