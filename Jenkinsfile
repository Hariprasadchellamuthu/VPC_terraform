pipeline {

    parameters {
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
        choice(name: 'awsService', choices: ['EC2', 'S3'], description: 'Select AWS Service to Create')
    } 
    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
    }

   agent  any
    stages {
        stage('checkout') {
            steps {
                 script{
                     def repoUrl = ''
                     def subDirectory = ''
                    if (params.awsService == 'EC2') {
                        repoUrl = "https://github.com/Hariprasadchellamuthu/terraorm-s3-ec2-2.git"
                        subDirectory = 'ec2'
                    } else if (params.awsService == 'S3') {
                               repoUrl =  "https://github.com/Hariprasadchellamuthu/terraorm-s3-ec2-2.git"
                               subDirectory = 's3' 
                    } else {
                                error("Invalid AWS service selection")
                            }
                    checkout([$class: 'GitSCM', branches: [[name: '*/main']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'YOUR_CREDENTIALS_ID', url: repoUrl]]])
                     dir(subDirectory) {
                        }
                    }
                }
            }

        stage('Plan') {
            steps {
                sh "terraform init"
                sh "terraform plan -out tfplan"
                sh "terraform show -no-color tfplan > tfplan.txt"
                sh "ls -l" 
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
                    def plan = readFile 'tfplan.txt'
                    input message: "Do you want to apply the plan?",
                    parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
               }
           }
       }

        stage('Apply') {
            steps {
                sh "terraform apply -input=false tfplan"
            }
        }
    }

  }
