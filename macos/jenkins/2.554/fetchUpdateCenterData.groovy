#!groovy

import jenkins.model.Jenkins

def uc = Jenkins.instance.updateCenter
def sites = uc.sites

def futures = uc.updateAllSites()
futures.each { f ->
  try { f.get() } catch (Throwable t) { t.printStackTrace() }
}