pipeline {
    parameters {
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
        string(name: 'vpcCidrBlock', defaultValue: '10.0.0.0/16', description: 'VPC CIDR block')
        string(name: 'publicSubnetCount', defaultValue: '2', description: 'Number of public subnets (as string)')
        string(name: 'privateSubnetCount', defaultValue: '2', description: 'Number of private subnets (as string)')
        string(name: 'publicSubnetCidrBlock', defaultValue: '10.0.1.0/24', description: 'CIDR block for public subnets')
        string(name: 'privateSubnetCidrBlock', defaultValue: '10.0.2.0/24', description: 'CIDR block for private subnets')
    }

    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
    }

    agent any

    stages {
        stage('checkout') {
            steps {
                script {
                    dir("terraform") {
                        git "https://github.com/Hariprasadchellamuthu/Terraform-Jenkins.git"
                    }
                }
            }
        }

        stage('Plan') {
            steps {
                sh 'pwd;cd terraform/ ; terraform init'
                sh 'pwd;cd terraform/ ; terraform plan -out tfplan \\
                    -var 'vpc_cidr_block=${params.vpcCidrBlock}' \\
                    -var 'public_subnet_count=${params.publicSubnetCount}' \\
                    -var 'private_subnet_count=${params.privateSubnetCount}' \\
                    -var 'public_subnet_cidr_blocks=${params.publicSubnetCidrBlock}' \\
                    -var 'private_subnet_cidr_blocks=${params.privateSubnetCidrBlock}'                
                sh 'pwd;cd terraform/ ; terraform show -no-color tfplan > tfplan.txt'
            }
        }

        stage('Approval') {
            when {
                not {
                    equals expected: true, actual: params.autoApprove
                }
            }
            steps {
                script {
                    def plan = readFile 'terraform/tfplan.txt'
                    input message: "Do you want to apply the plan?",
                        parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
                }
            }
        }

        stage('Apply') {
            when {
                expression {
                    return params.autoApprove || currentBuild.rawBuild.resultIsBetterOrEqualTo('SUCCESS')
                }
            }
            steps {
                sh "pwd;cd terraform/ ; terraform apply -input=false tfplan"
            }
        }
    }
}
