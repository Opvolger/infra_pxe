#!groovy

import jenkins.model.*
import hudson.security.*

def instance = Jenkins.getInstance()

currentAuthenticationStrategy = Jenkins.instance.getAuthorizationStrategy()

if (!(currentAuthenticationStrategy instanceof FullControlOnceLoggedInAuthorizationStrategy)) {
    println "creating local admin-user '{{ jenkins.username }}'"
    def hudsonRealm = new HudsonPrivateSecurityRealm(false)
    hudsonRealm.createAccount('{{ jenkins.username }}','{{ jenkins.password }}')
    instance.setSecurityRealm(hudsonRealm)
    println "change current AuthenticationStrategy to FullControlOnceLoggedInAuthorizationStrategy"
    def authStrategy = new FullControlOnceLoggedInAuthorizationStrategy()
    authStrategy.setAllowAnonymousRead(false);
    instance.setAuthorizationStrategy(authStrategy)
}

instance.save()