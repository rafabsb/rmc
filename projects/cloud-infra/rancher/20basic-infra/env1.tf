
#####
## CREATE RANCHER DEFAULT ENVIRONMENT
#####

resource "rancher_environment" "env1" {  
  name = "env1"  
  orchestration = "cattle" 
  description = "Default env1"  

}

resource "rancher_registration_token" "env1-token" {  
  environment_id = "${rancher_environment.env1.id}"  
  name = "env1-token"  
  description = "Host registration token for Env1 environment"


  provisioner "local-exec" {
    command = "sleep 3; export ADD_AGENT_CMD='${rancher_registration_token.env1-token.command}'; ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ../../../../clouds/coreos-vagrant/.vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory addHostsPlaybook.yml" 
  }

}