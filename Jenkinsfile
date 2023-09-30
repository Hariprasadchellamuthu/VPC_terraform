pipeline {
    parameters {
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
        choice(name: 'action', choices: ['Apply', 'Destroy'], description: 'Choose whether to apply or destroy the VPC.')
        string(name: 'vpcCidrBlock', defaultValue: '10.0.0.0/16', description: 'VPC CIDR block')
        string(name: 'publicSubnetCount', defaultValue: '2', description: 'Number of public subnets (as string)')
        string(name: 'privateSubnetCount', defaultValue: '2', description: 'Number of private subnets (as string)')
        string(name: 'publicSubnetCidrBlock', defaultValue: '10.0.1.0/24', description: 'CIDR block for public subnets')
        string(name: 'privateSubnetCidrBlock', defaultValue: '10.0.2.0/24', description: 'CIDR block for private subnets')
        string(name: 'availability_zone', defaultValue: '2', description: 'Number of Availability Zone (as string)')
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
                        checkout([$class: 'GitSCM', branches: [[name: 'main']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[url: 'https://github.com/Hariprasadchellamuthu/VPC_terraform.git']]])
                    }
                }
            }
        }

        stage('Plan') {
            steps {
    
                    sh """
                        pwd
                        cd terraform/
                        terraform init
                        terraform plan -out tfplan \
                            -var='vpc_cidr_block=${params.vpcCidrBlock}' \
                            -var='public_subnet_count=${params.publicSubnetCount}' \
                            -var='private_subnet_count=${params.privateSubnetCount}' \
                            -var='public_subnet_cidr_blocks=${params.publicSubnetCidrBlock}' \
                            -var='private_subnet_cidr_blocks=${params.privateSubnetCidrBlock}' \
                            -var='azs=${params.availability_zone}'
                        terraform show -no-color tfplan > tfplan.txt
                        """

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

        stage('Terraform Apply or Destroy') {
            steps {
                script {
                    dir('terraform') {
                        if (params.action == 'Apply') {
                            sh 'terraform apply -input=false tfplan'
                        } else if (params.action == 'Destroy') {
                            sh 'terraform destroy -auto-approve'
                        } else {
                            error "Invalid action: ${params.action}. Please choose 'Apply' or 'Destroy'."
                        }
                    }
                }
            }
        }
    }
}
