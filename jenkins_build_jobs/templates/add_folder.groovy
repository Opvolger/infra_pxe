import com.cloudbees.hudson.plugins.folder.*
import org.jenkinsci.plugins.workflow.job.WorkflowJob
import jenkins.model.Jenkins

Jenkins jenkins = Jenkins.instance // saves some typing

// Bring some values in from ansible using the jenkins_script modules wierd "args" approach (these are not gstrings)
String folderName = "{{ folder }}"

def folder = jenkins.getItem(folderName)
if (folder == null) {
    // Create the folder if it doesn't exist or if no existing job has the same name
    folder = jenkins.createProject(Folder.class, folderName)
    println "created folder ${folderName}"
}else{
    println "folder ${folderName} exists"
}