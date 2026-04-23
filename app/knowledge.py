KNOWLEDGE_BASE = {
    "tech challenge 1": "Tech Challenge 1 focuses on setting up a basic web application and deploying it to AWS EC2 using a CI/CD pipeline.",
    "tech challenge 2": "Tech Challenge 2 focuses on containerizing an application using Docker and automating deployment through Jenkins or GitHub Actions.",
    "tech challenge 3": "Tech Challenge 3 involves setting up autoscaling on AWS and configuring load balancers to handle traffic automatically.",
    "jenkins": "Jenkins is used in Tech Pathway for building CI/CD pipelines. It automates the build, test, and deployment stages of your application.",
    "github actions": "GitHub Actions is used as an alternative to Jenkins for CI/CD. It runs automated pipelines directly from your GitHub repository.",
    "docker": "Docker is used to containerize applications so they run consistently across different environments.",
    "aws": "AWS is the cloud platform used in Tech Pathway. You deploy applications to EC2 instances and use services like IAM, VPC, and Security Groups.",
    "ec2": "EC2 is the AWS virtual server service used to host and run your backend applications in Tech Pathway.",
    "autoscaling": "The autoscaling project involves configuring AWS Auto Scaling Groups so your application automatically adds or removes servers based on traffic.",
    "migration project": "The migration project involves moving an existing application from a local environment to AWS, setting up proper networking, security, and deployment pipelines.",
    "slack bot": "The Slack bot project involves building a backend service that receives messages from Slack, processes them, and returns responses using internal knowledge.",
    "ci/cd": "CI/CD stands for Continuous Integration and Continuous Deployment. In Tech Pathway, you build pipelines that automatically test and deploy your code when changes are pushed.",
    "python": "Python is one of the backend languages used in Tech Pathway for building APIs and automation scripts.",
    "node": "Node.js is one of the backend language options in Tech Pathway for building backend services.",
    "iam": "IAM stands for Identity and Access Management. It is used in AWS to control who has access to which resources.",
    "vpc": "VPC stands for Virtual Private Cloud. It is the isolated network environment inside AWS where your resources live.",
    "security group": "A Security Group in AWS acts as a virtual firewall that controls inbound and outbound traffic to your EC2 instances.",
}


def find_answer(question: str) -> str:
    question = question.lower().strip()

    for keyword, answer in KNOWLEDGE_BASE.items():
        if keyword in question:
            return answer

    return None # type: ignore