
provider "rancher" {
  api_url = "http://192.168.71.101:8080" //
  access_key = "" //
  secret_key = "" 
}


#####################################
## CREATE RANCHER DEFAULT ENVIRONMENT
#####################################

resource "rancher_environment" "env1" {  
  name = "env1"  
  orchestration = "cattle" 
  description = "Default env1"  

}


######################################################
## CREATE REGISTRATION TOKEN & ADD RANCHER-AGENT HOSTS
######################################################

resource "rancher_registration_token" "env1-token" {
  environment_id = "${rancher_environment.env1.id}"  
  name = "env1-token"  
  description = "Host registration token for Env1 environment"


  provisioner "local-exec" {
    command = "sleep 3; export ADD_AGENT_CMD='${rancher_registration_token.env1-token.command}'; ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ../../../../clouds/coreos-vagrant/.vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory addHostsPlaybook.yml" 
  }



}

resource rancher_host "core-01" {
  name           = "core-01"
  description    = "The core-01 node"
  environment_id = "${rancher_environment.env1.id}"
  hostname       = "core-01"

}

resource rancher_host "core-02" {
  name           = "core-02"
  description    = "The core-02 node"
  environment_id = "${rancher_environment.env1.id}"
  hostname       = "core-02"
  labels {
    "dns_geral"="true"
  }
}

resource rancher_host "core-03" {
  name           = "core-03"
  description    = "The core-03 node"
  environment_id = "${rancher_environment.env1.id}"
  hostname       = "core-03"
  labels {
    "dns_geral"="true"

  }
}


resource "rancher_stack" "nfs" {  
  environment_id = "${rancher_environment.env1.id}"
  name = "nfs"  
  description = "NFS Rancher"
  catalog_id = "library:infra*nfs:4"  
  scope = "system"
  start_on_create = true
  finish_upgrade = true
  environment {  
    NFS_SERVER="192.168.69.101"
    MOUNT_DIR="/exports"
    MOUNT_OPTS=""
    NFS_VERS="nfsvers=4"
    ON_REMOVE="purge"
    RANCHER_DEBUG="false"

  }
}

resource "rancher_stack" "traefik" {  
  environment_id = "${rancher_environment.env1.id}"
  name = "traefik"  
  description = "Http Load Balancer Rancher"
  catalog_id = "community:traefik:16"  
  scope = "system"
  start_on_create = true
  finish_upgrade = true
  environment {  
    rancher_integration="metadata"
    rancher_healthcheck="false"
    constraints=""
    host_label="dns_geral=true"
    http_port=80
    https_port=443
    admin_port=8000
    https_enable=false
    https_min_tls=""
    acme_enable="false"
    acme_email="test@traefik.io"
    acme_ondemand="true"
    acme_onhostrule=true
    acme_caserver="https://acme-v01.api.letsencrypt.org/directory"
    acme_vol_name="traefik_acme_vol"
    acme_vol_driver="local"
    ssl_key=""
    ssl_crt=""
    insecure_skip="false"
    compress_enable="true"
    admin_readonly="false"
    admin_statistics="10"
    admin_auth_method="basic"
    admin_users=""
    prometheus_enable="false"
    prometheus_buckets="[0.1,0.3,1.2,5.0]"
    cattle_url=""
    cattle_access_key=""
    cattle_secret_key=""

  }
}


##########################
## REGISTRAR CATALOGO ITOA
##########################

resource "null_resource" "catalog" {

  provisioner "local-exec" {
    command = <<EOF
curl -X PUT http://192.168.71.101:8080/v2-beta/settings/catalog.url -H 'cache-control: no-cache' -H 'content-type: application/json' -d '{"id":"catalog.url","type":"activeSetting","baseType":"setting","name":"catalog.url","activeValue":"{\"catalogs\":{\"library\":{\"url\":\"https://git.rancher.io/rancher-catalog.git\",\"branch\":\"$${RELEASE}\"},\"community\":{\"url\":\"https://git.rancher.io/community-catalog.git\",\"branch\":\"master\"},\"itoa\":{\"url\":\"http://gogs.lcl.rafabsb.me:10080/rafabsb/catalog.git\",\"branch\":\"master\"}}}","inDb":true,"source":"Database","value":"{\"catalogs\":{\"library\":{\"url\":\"https://git.rancher.io/rancher-catalog.git\",\"branch\":\"$${RELEASE}\"},\"community\":{\"url\":\"https://git.rancher.io/community-catalog.git\",\"branch\":\"master\"},\"itoa\":{\"url\":\"http://gogs.lcl.rafabsb.me:10080/rafabsb/catalog.git\",\"branch\":\"master\"}}}"}'
EOF


  }

}

#resource "rancher_stack" "gogs" {  
#  environment_id = "${rancher_environment.env1.id}"
#  name = "gogs"  
#  description = "GOGS Git"
#  catalog_id = "itoa:gogs:1"  
#  scope = "system"
#  start_on_create = true
#  finish_upgrade = true
#  environment {  
#    ssh_port=2222
#    VOLUME_DRIVER="local"
#    mysql_db="gogs"
#    mysql_user="gogs"
#    mysql_password=12345678
#  }
#}

