# --------------------------------------------------------------
# Create free tier cluster (only one allowed per Atlas account)
# --------------------------------------------------------------
resource "mongodbatlas_cluster" "cluster-demo" {
  project_id                  = data.external.env_vars.result.MONGODB_ATLAS_PROJECT_ID
  name                        = var.cluster_name_mongodb
  provider_name               = var.provider_name_mongodb
  backing_provider_name       = var.cloud_provider_mongodb
  provider_region_name        = var.cloud_region_mongodb
  provider_instance_size_name = var.provider_instance_size_name_mongodb
  lifecycle {
    prevent_destroy = false
  }
}
output "standard_srv" {
  # Connection string
  value = mongodbatlas_cluster.cluster-demo.connection_strings[0].standard_srv
}

# --------------------------------------------------------
# Whitelist IP Address
# --------------------------------------------------------
resource "mongodbatlas_project_ip_access_list" "my-public-ip" {
  project_id = data.external.env_vars.result.MONGODB_ATLAS_PROJECT_ID
  cidr_block = data.external.env_vars.result.MONGODB_ATLAS_PUBLIC_IP_ADDRESS
  comment    = "cidr block for ${var.cluster_name_mongodb}"
  lifecycle {
    prevent_destroy = false
  }
}

# --------------------------------------------------------
# Create DB user
# --------------------------------------------------------
resource "mongodbatlas_database_user" "mongodb-user" {
  username           = var.username_mongodb
  password           = random_password.mongodb-password.result
  project_id         = data.external.env_vars.result.MONGODB_ATLAS_PROJECT_ID
  auth_database_name = "admin"
  roles {
    role_name     = "dbAdmin"
    database_name = var.database_mongodb
  }
  roles {
    role_name     = "readWrite"
    database_name = var.database_mongodb
  }
  lifecycle {
    prevent_destroy = false
  }
}
output "mongodb-password" {
  value     = random_password.mongodb-password.result
  sensitive = true
}

# --------------------------------------------------------
# MongoDB Sink Connector
# --------------------------------------------------------
resource "confluent_connector" "mongo_db_sink" {
  environment {
    id = confluent_environment.cc_demo_env.id
  }
  kafka_cluster {
    id = confluent_kafka_cluster.cc_kafka_cluster.id
  }
  config_sensitive = {
    "connection.password" = random_password.mongodb-password.result,
  }
  config_nonsensitive = {
    "connector.class"          = "MongoDbAtlasSink"
    "name"                     = "confluent-mongodb-sink"
    "kafka.auth.mode"          = "SERVICE_ACCOUNT"
    "kafka.service.account.id" = confluent_service_account.connectors.id
    "write.strategy"           = "DefaultWriteModelStrategy",
    "database"                 = var.database_mongodb
    "connection.user"          = var.username_mongodb
    "connection.host"          = split("//", mongodbatlas_cluster.cluster-demo.srv_address)[1]
    "input.data.format"        = "AVRO"
    "topics"                   = "demo-accomplished-females"
    "max.num.retries"          = "3"
    "retries.defer.timeout"    = "5000"
    "max.batch.size"           = "0"
    "collection"               = "accomplished_female_readers"
    "tasks.max"                = "1"
  }
  lifecycle {
    prevent_destroy = false
  }
  depends_on = [
    mongodbatlas_cluster.cluster-demo,
  ]
}
output "mongo_db_sink" {
  description = "CC MongoDB Sink Connector ID"
  value       = resource.confluent_connector.mongo_db_sink.id
}
