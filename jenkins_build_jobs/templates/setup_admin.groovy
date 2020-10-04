#!groovy

import jenkins.model.*
import hudson.security.*

def instance = Jenkins.getInstance()

println "--> creating local user 'admin'"

def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount('{{ jenkins.username }}','{{ jenkins.password }}')
instance.setSecurityRealm(hudsonRealm)

def authStrategy = new FullControlOnceLoggedInAuthorizationStrategy()
authStrategy.setAllowAnonymousRead(false);
instance.setAuthorizationStrategy(authStrategy)
instance.save()
