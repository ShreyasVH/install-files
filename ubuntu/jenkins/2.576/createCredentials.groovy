import com.cloudbees.plugins.credentials.*
import com.cloudbees.plugins.credentials.domains.*
import com.cloudbees.plugins.credentials.impl.*
import jenkins.model.*

def store = Jenkins.instance
    .getExtensionList('com.cloudbees.plugins.credentials.SystemCredentialsProvider')[0]
    .getStore()


def githubUsername = args[0].toString()
def githubToken = args[1].toString()
def id = args[2].toString()
def description = args[3].toString()

def creds = new UsernamePasswordCredentialsImpl(
    CredentialsScope.GLOBAL,
    id,        // ID
    description, // Description
    githubUsername,
    githubToken
)

store.addCredentials(Domain.global(), creds)