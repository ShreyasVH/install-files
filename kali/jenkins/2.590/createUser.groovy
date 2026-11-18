#!groovy

import jenkins.model.*
import hudson.security.*

def instance = Jenkins.getInstance()

def username = args[0].toString()
def password = args[1].toString()

def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount(username, password)
instance.setSecurityRealm(hudsonRealm)

def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
strategy.setAllowAnonymousRead(false)
instance.setAuthorizationStrategy(strategy)

instance.save()