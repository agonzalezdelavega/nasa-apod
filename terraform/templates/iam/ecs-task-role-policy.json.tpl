{
	"Version": "2012-10-17",
	"Statement": [
        {
			"Sid": "getKMSKey",
			"Effect": "Allow",
			"Action": "kms:Decrypt",
			"Resource": "${kms_key_arn}"          
        },
        {
			"Sid": "getAPIKey",
			"Effect": "Allow",
			"Action": "secretsmanager:GetSecretValue",
			"Resource": "${api_key_arn}"
		},
		{
			"Sid": "dynamoDBFavorites",
			"Effect": "Allow",
			"Action": [
				"dynamodb:PutItem",
				"dynamodb:GetItem",
				"dynamodb:UpdateItem"
			],
			"Resource": [
				"arn:aws:dynamodb:${aws_region}:${account}:table/${dynamo_db_favorites_table_name}"
			]
		},
		{
			"Sid": "dynamoDBSessions",
			"Effect": "Allow",
			"Action": [
				"dynamodb:CreateTable",
				"dynamodb:DescribeTable",
				"dynamodb:PutItem",
				"dynamodb:DeleteItem",
				"dynamodb:GetItem",
				"dynamodb:Scan",
				"dynamodb:UpdateItem"
			],
			"Resource": [
				"arn:aws:dynamodb:${aws_region}:${account}:table/${dynamo_db_sessions_table_name}"
			]
		},
		{
			"Sid": "cognito",
			"Effect": "Allow",
			"Action": [
				"cognito-idp:GlobalSignOut",
				"cognito-idp:SignUp",
				"cognito-idp:InitiateAuth"
			],
			"Resource": "*"
		}
	]
}