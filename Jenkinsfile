node () {

deleteDir()

      stage ('Checkout Build Code') {
         checkout scm
       }

        withCredentials([usernamePassword(credentialsId: 'nsxCredentials',
        usernameVariable: 'NSXUSERNAME', passwordVariable: 'NSXPASSWORD')]) {
        stage ('Execute Terraform Template') {
        sh '/usr/bin/terraform init'
        sh '/usr/bin/terraform providers'
        sh '/usr/bin/terraform apply -state="/var/lib/jenkins/terraform/multi-site-vdi-s1.tfstate" -auto-approve -var nsxIP="10.1.1.30" -var nsxUser="$NSXUSERNAME" -var nsxPassword="$NSXPASSWORD"'
        sh '/usr/bin/terraform apply -state="/var/lib/jenkins/terraform/multi-site-vdi-s2.tfstate" -auto-approve -var nsxIP="10.2.1.30" -var nsxUser="$NSXUSERNAME" -var nsxPassword="$NSXPASSWORD"' 
        }
    }
}
