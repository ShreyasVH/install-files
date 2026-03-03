#!groovy

import jenkins.model.Jenkins

def uc = Jenkins.instance.updateCenter
def sites = uc.sites
println "Update sites: " + sites.collect { it.id + " -> " + it.url }

def futures = uc.updateAllSites()
futures.each { f ->
  try { f.get() } catch (Throwable t) { t.printStackTrace() }
}
println "Update center data refresh done."