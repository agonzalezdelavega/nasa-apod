{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "getParameterAPIKey",
			"Effect": "Allow",
			"Action": "ssm:GetParameter",
			"Resource": "arn:aws:ssm:*:*:parameter/nasa-api-key"
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