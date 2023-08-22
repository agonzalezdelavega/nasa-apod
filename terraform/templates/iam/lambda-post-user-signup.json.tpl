{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "dynamoDBFavorites",
			"Effect": "Allow",
			"Action": [
				"dynamodb:PutItem"
			],
			"Resource": [
				"arn:aws:dynamodb:${aws_region}:${account}:table/${dynamo_db_favorites_table_name}"
			]
		},
		{
			"Sid": "vpcConnect",
			"Effect": "Allow",
			"Action": [
				"ec2:CreateNetworkInterface",
				"ec2:DescribeNetworkInterfaces",
				"ec2:DeleteNetworkInterface"
			],
			"Resource": "*"
		},
		{
			"Sid": "kmsDecrypt",
			"Effect": "Allow",
			"Action": [
				"kms:Decrypt"
			],
			"Resource": [
				"arn:aws:kms:us-east-2:150111004124:key/${key_id}"
			]
		}
	]
}