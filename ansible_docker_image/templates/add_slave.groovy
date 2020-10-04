#!groovy
import jenkins.model.*
import hudson.model.*
import hudson.slaves.*
import hudson.plugins.sshslaves.*
import hudson.plugins.sshslaves.verifiers.*
import java.util.ArrayList;
import hudson.slaves.EnvironmentVariablesNodeProperty.Entry;

{% for slave in jenkins.slaves %}
println "Searching for slave docker";
slave = Hudson.instance.slaves.find({it.name == "{{ slave.name }}"});
if (slave == null) {
    println "slave docker not found";

    // Prepare env vars for slave node
    List<Entry> env = new ArrayList<Entry>();
{% for environment in slave.environments %}
    env.add(new Entry("{{ environment.key }}","{{ environment.value }}"))
{% endfor %}
    EnvironmentVariablesNodeProperty envPro = new EnvironmentVariablesNodeProperty(env);
    
    // Pick one of the strategies from the comments below this line
    SshHostKeyVerificationStrategy hostKeyVerificationStrategy = new NonVerifyingKeyVerificationStrategy()
        //= new KnownHostsFileKeyVerificationStrategy() // Known hosts file Verification Strategy
        //= new ManuallyProvidedKeyVerificationStrategy("<your-key-here>") // Manually provided key Verification Strategy
        //= new ManuallyTrustedKeyVerificationStrategy(false /*requires initial manual trust*/) // Manually trusted key Verification Strategy
        //= new NonVerifyingKeyVerificationStrategy() // Non verifying Verification Strategy
    
    // Define a "Launch method": "Launch agents via SSH"
    ComputerLauncher launcher = new hudson.plugins.sshslaves.SSHLauncher(
            "{{ slave.hostname }}", // Host
            22, // Port
            "ssh_creds_{{ slave.hostname }}", // Credentials
            (String)null, // JVM Options
            (String)null, // JavaPath
            (String)null, // Prefix Start Agent Command
            (String)null, // Suffix Start Agent Command
            (Integer)null, // Connection Timeout in Seconds
            (Integer)null, // Maximum Number of Retries
            (Integer)null, // The number of seconds to wait between retries
            hostKeyVerificationStrategy // Host Key Verification Strategy
	)  
  
    // Define slave to be bootstrapped by master
    Slave slave = new DumbSlave(
        "{{ slave.hostname }}", // name
        "Slave {{ slave.hostname }} has {{ slave.labels }}",
        "{{ slave.home_dir }}",
        "{{ slave.executors }}", // # of executors
        Node.Mode.EXCLUSIVE,
        "{{ slave.labels }}", // labels
        launcher,
        new RetentionStrategy.Always(),
        new LinkedList()
    )

    // Add env vars to slave
    slave.getNodeProperties().add(envPro)

    // Save slave
    Jenkins.instance.addNode(slave)
} else {
    println "slave docker found";
}
{% endfor %}