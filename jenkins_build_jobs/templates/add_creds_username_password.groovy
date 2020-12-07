// imports
import com.cloudbees.plugins.credentials.*
import com.cloudbees.plugins.credentials.domains.Domain
import com.cloudbees.plugins.credentials.impl.*
import hudson.util.Secret
import jenkins.model.Jenkins

def createOrchangePassword = { id, username, password, description ->
    def creds = com.cloudbees.plugins.credentials.CredentialsProvider.lookupCredentials(
        com.cloudbees.plugins.credentials.common.StandardUsernameCredentials.class,
        Jenkins.instance
    )

    def c = creds.findResult { it.id == id ? it : null }

    if ( c ) {
        println "found credential ${c.id} for username ${c.username}"

        if ( c.password.toString().equals(password)) {
            println "no password changed for ${username}"
        } else {
            def credentials_store = Jenkins.instance.getExtensionList(
                'com.cloudbees.plugins.credentials.SystemCredentialsProvider'
                )[0].getStore()

            def result = credentials_store.updateCredentials(
                com.cloudbees.plugins.credentials.domains.Domain.global(), 
                c, 
                new UsernamePasswordCredentialsImpl(c.scope, c.id, description, username, password)
                )

            if (result) {
                println "changed: password changed for ${username}"
            } else {
                println "failed to change password for ${username}"
            }
        }
    } else {
        // parameters
        def jenkinsKeyUsernameWithPasswordParameters = [
            description:  description,
            id:           id,
            secret:       password,
            userName:     username
        ]

        // get Jenkins instance
        Jenkins jenkins = Jenkins.getInstance()

        // get credentials domain
        def domain = Domain.global()

        // get credentials store
        def store = jenkins.getExtensionList('com.cloudbees.plugins.credentials.SystemCredentialsProvider')[0].getStore()

        // define Bitbucket secret
        def jenkinsKeyUsernameWithPassword = new UsernamePasswordCredentialsImpl(
            CredentialsScope.GLOBAL,
            jenkinsKeyUsernameWithPasswordParameters.id,
            jenkinsKeyUsernameWithPasswordParameters.description,
            jenkinsKeyUsernameWithPasswordParameters.userName,
            jenkinsKeyUsernameWithPasswordParameters.secret
        )

        // add credential to store
        store.addCredentials(domain, jenkinsKeyUsernameWithPassword)

        // save to disk
        jenkins.save()

        println "changed: add credentials for ${id} and ${username}"
    }
}

createOrchangePassword('{{ id }}','{{ username }}', '{{ secret }}', '{{ description }}')