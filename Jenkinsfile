pipeline {
    parameters {
        string(name: 'vpcCidrBlock', defaultValue: '10.0.0.0/16', description: 'VPC CIDR block')
        int(name: 'publicSubnetCount', defaultValue: 2, description: 'Number of public subnets')
        int(name: 'privateSubnetCount', defaultValue: 2, description: 'Number of private subnets')
        string(name: 'publicSubnetCidrBlock', defaultValue: '10.0.1.0/24', description: 'CIDR block for public subnets')
        string(name: 'privateSubnetCidrBlock', defaultValue: '10.0.2.0/24', description: 'CIDR block for private subnets')
    }
    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
    }

    agent any

    stages {
        stage('Checkout') {
            steps {
			   script {
				   dir("terraform") {
					   git "https://github.com/Hariprasadchellamuthu/VPC_terraform.git"
                   }           
				}
			}
        }

        stage('Terraform Init and Apply') {
            steps {
                script {
                    def vpcCidr = params.vpcCidrBlock
                    def publicSubnetCount = params.publicSubnetCount
                    def privateSubnetCount = params.privateSubnetCount
                    def publicSubnetCidr = params.publicSubnetCidrBlock
                    def privateSubnetCidr = params.privateSubnetCidrBlock

                    // Set environment variables for Terraform
                    env.VPC_CIDR = vpcCidr
                    env.PUBLIC_SUBNET_COUNT = publicSubnetCount
                    env.PRIVATE_SUBNET_COUNT = privateSubnetCount
                    env.PUBLIC_SUBNET_CIDR = publicSubnetCidr
                    env.PRIVATE_SUBNET_CIDR = privateSubnetCidr

                    // Run Terraform commands (init and apply)
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
                }
            }
        }
    }
}
