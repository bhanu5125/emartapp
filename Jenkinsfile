pipeline {
    agent any
    
    environment {
        AWS_DEFAULT_REGION = 'us-west-2'
        ECR_REGISTRY = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
        CLUSTER_NAME = 'emart-cluster'
        BUILD_NUMBER = "${env.BUILD_NUMBER}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scmGit(
                    branches: [[name: '*/main']], 
                    extensions: [], 
                    userRemoteConfigs: [[url: 'https://github.com/devopshydclub/emartapp.git']]
                )
            }
        }
        
        stage('Build Docker Images') {
            parallel {
                stage('Build Client') {
                    steps {
                        script {
                            dir('client') {
                                sh 'docker build -t emart/client:${BUILD_NUMBER} .'
                            }
                        }
                    }
                }
                stage('Build Node API') {
                    steps {
                        script {
                            dir('nodeapi') {
                                sh 'docker build -t emart/nodeapi:${BUILD_NUMBER} .'
                            }
                        }
                    }
                }
                stage('Build Java API') {
                    steps {
                        script {
                            dir('javaapi') {
                                sh 'docker build -t emart/javaapi:${BUILD_NUMBER} .'
                            }
                        }
                    }
                }
            }
        }
        
        stage('Security Scan') {
            parallel {
                stage('Scan Client') {
                    steps {
                        sh 'trivy image --exit-code 0 --severity HIGH,CRITICAL emart/client:${BUILD_NUMBER}'
                    }
                }
                stage('Scan Node API') {
                    steps {
                        sh 'trivy image --exit-code 0 --severity HIGH,CRITICAL emart/nodeapi:${BUILD_NUMBER}'
                    }
                }
                stage('Scan Java API') {
                    steps {
                        sh 'trivy image --exit-code 0 --severity HIGH,CRITICAL emart/javaapi:${BUILD_NUMBER}'
                    }
                }
            }
        }
        
        stage('Push to ECR') {
            steps {
                script {
                    sh 'aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}'
                    
                    ['client', 'nodeapi', 'javaapi'].each { service ->
                        sh """
                            docker tag emart/${service}:${BUILD_NUMBER} ${ECR_REGISTRY}/emart/${service}:${BUILD_NUMBER}
                            docker tag emart/${service}:${BUILD_NUMBER} ${ECR_REGISTRY}/emart/${service}:latest
                            docker push ${ECR_REGISTRY}/emart/${service}:${BUILD_NUMBER}
                            docker push ${ECR_REGISTRY}/emart/${service}:latest
                        """
                    }
                }
            }
        }
        
        stage('Deploy to EKS') {
            steps {
                script {
                    sh 'aws eks update-kubeconfig --region ${AWS_DEFAULT_REGION} --name ${CLUSTER_NAME}'
                    sh 'kubectl apply -f kubernetes/manifests/'
                    sh 'kubectl set image deployment/emart-client client=${ECR_REGISTRY}/emart/client:${BUILD_NUMBER}'
                    sh 'kubectl set image deployment/emart-nodeapi nodeapi=${ECR_REGISTRY}/emart/nodeapi:${BUILD_NUMBER}'
                    sh 'kubectl set image deployment/emart-javaapi javaapi=${ECR_REGISTRY}/emart/javaapi:${BUILD_NUMBER}'
                }
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
        success {
            echo 'Pipeline succeeded!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
