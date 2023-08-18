# Using ECS to Create a NASA Image viewer

Every day, NASA publishes high-quality pictures in their [astronomy picture of the day website](https://apod.nasa.gov/apod/) for everyone to enjoy the wonderful sights above our skies. Using the [NASA APIs](https://api.nasa.gov/), we can build a highly available, cost effective image viewer on AWS that users can visit anytime to enjoy the beauty of our universe.

The architecture for this application leverages AWS resources to make a resilient application in which users can view images as well as sign up to save their favorites. The application is written in Node.js and hosted in AWS ECS Fargate containers, backed up by DynamoDB tables to store user favorites and session data. All infrastructure is managed with Terraform for fast, predictable deployments.

The ECS containers are lightweight, using the node-alpine image to host an express.js application. Using the AWS SDK, this application can reach Cognito to authenticate users and query DynamoDB for their favorite images, providing a quick and seamless experience. ECS Fargate is serverless and scalable, freeing up resources and ensuring minimum downtime for users.

Although NAT Gateways are usually recommended for their simplicity and scalability, this project uses NAT instances for their low cost. In this scenario, both solutions offer similar performance, however NAT instances can be provisioned for a significantly lower monthly cost. 

AWS Cognito is used as a solution for user account management. In this application, users can sign up to save their favorite images for repeated viewing. The application’s middleware also ensures that the user’s session remains safe by validating the user’s access tokens and by using the refresh token to renew sessions.
Finally, Route53 and ACM are leveraged to provision the application’s domain name and ensure a secure connection can be established.

Hope you enjoyed looking around at the incredible sights our universe has to offer! As someone who loves reading and learning about space, this has been an exciting project to work on. If you enjoyed visiting this website or would like to provide any suggestions or feedback, please feel free to reach out. I will continue to improve this application as consistently as I can, so all feedback is welcome.
