#!groovy

import jenkins.model.*
import org.jenkinsci.plugins.workflow.multibranch.WorkflowMultiBranchProject
import jenkins.branch.*
import jenkins.scm.api.*
import org.jenkinsci.plugins.github_branch_source.*
import com.cloudbees.hudson.plugins.folder.computed.DefaultOrphanedItemStrategy

def j = Jenkins.instance

def jobName = args[0].toString()
def repoOwner = args[1].toString()
def repository = args[2].toString()


def mbp = j.getItem(jobName)
if (mbp == null) {
  mbp = j.createProject(WorkflowMultiBranchProject, jobName)
}

// Configure branch source (GitHub)
def githubSource = new GitHubSCMSource(repoOwner, repository)
githubSource.setCredentialsId("github-creds")     // Jenkins credential id
githubSource.setId("github-${repoOwner}-${repository}")

githubSource.traits = [
  new BranchDiscoveryTrait(1),

  new OriginPullRequestDiscoveryTrait(2),

  new ForkPullRequestDiscoveryTrait(2, new ForkPullRequestDiscoveryTrait.TrustPermission())
]

def branchSource = new BranchSource(githubSource)
mbp.getSourcesList().clear()
mbp.getSourcesList().add(branchSource)

mbp.setOrphanedItemStrategy(new DefaultOrphanedItemStrategy(true, "", ""))

// mbp.addTrigger(new com.cloudbees.hudson.plugins.folder.computed.PeriodicFolderTrigger("1m"))

mbp.save()

// println "Created/updated multibranch job: ${jobName}"

// mbp.scheduleBuild2(0)

// println "Indexing finished"
