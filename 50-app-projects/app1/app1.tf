###################
## PROJECT METADATA
###################

variable "project" {
  type = "map"

  default = {
    name = "app1"
    number = "12345"
    ssti = "11236"
    rli = "2018/0001"
  }
}


##########################
## DEFINE RANCHER PROVIDER
##########################


provider "rancher" {
  api_url = "http://192.168.71.101:8080" //
  access_key = "" //
  secret_key = "" 
}


###############################
## GET RANCHER ENVIRONMENT DATA
###############################


data "rancher_environment" "env1" {
  name = "env1"
}


###################################
## APP1 - COMPLETE INFRA DEFINITION
###################################


# ELASTICSEARCH STACK
resource "rancher_stack" "es-stack" {  
  environment_id = "${data.rancher_environment.env1.id}"
  name = "es-stack-${var.project["name"]}"  
  description = "On demand Elastic Stack"
  catalog_id = "itoa:es-stack:11"  
  scope = "user"
  start_on_create = true
  finish_upgrade = true
  environment {  
    master_heap_size=256
    data_heap_size=512
    client_heap_size=256
    VOLUME_DRIVER="local"
  }
}

resource "rancher_stack" "msql-docker" {  
  environment_id = "${data.rancher_environment.env1.id}"
  name = "msql-docker-${var.project["name"]}"  
  description = "My SQL docker"
  catalog_id = "itoa:MySQL-Docker:1"  
  scope = "user"
  start_on_create = true
  finish_upgrade = true
  environment {  
    MYSQL_ROOT_PASSWORD=12345678
    MYSQL_DATABASE="itoa"
    MYSQL_USER="itoa"
    MYSQL_PASSWORD=12345678
    DB_PROXY_PORT=22222
    VOLUME_DRIVER="local"
    PHP_ADMIN=true
  }
}




