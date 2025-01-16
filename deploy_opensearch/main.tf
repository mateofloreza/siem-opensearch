terraform {
  required_version = ">= 1.6"
  required_providers {
    juju = {
      source  = "juju/juju"
      version = "~> 0.14.0"
    }
  }
}

locals {
  juju_model_name = "opensearch-demo"
  base            = "ubuntu@22.04"
}

resource "juju_application" "data_integrator" {
  name  = "data-integrator"
  model = local.juju_model_name

  charm {
    name     = "data-integrator"
    channel  = "latest/stable"
    base     = local.base
  }

  units       = 1
  config = {
    extra-user-roles = "admin"
    index-name       = "sflow"
  }
}

resource "juju_application" "opensearch" {
  name  = "opensearch"
  model = local.juju_model_name

  charm {
    name     = "opensearch"
    channel  = "2/stable"
    base     = local.base
  }

  units       = 3
  config = {
    cluster_name = "sflow"
  }
}

resource "juju_application" "opensearch_dashboards" {
  name  = "opensearch-dashboards"
  model = local.juju_model_name

  charm {
    name     = "opensearch-dashboards"
    channel  = "2/stable"
    base     = local.base
  }

  units       = 1
  config      = {}
}

resource "juju_application" "self_signed_certificates" {
  name  = "self-signed-certificates"
  model = local.juju_model_name

  charm {
    name    = "self-signed-certificates"
    channel = "latest/stable"
    base    = local.base
  }

  units       = 1
  config = {
    ca-common-name = "sflow"
  }
}

resource "juju_integration" "opensearch_dashboards" {
  model = local.juju_model_name

  application {
    name     = juju_application.opensearch.name
    endpoint = "opensearch-client"
  }
  application {
    name     = juju_application.opensearch_dashboards.name
    endpoint = "opensearch-client"
  }
}

resource "juju_integration" "opensearch_data_integrator" {
  model = local.juju_model_name

  application {
    name     = juju_application.data_integrator.name
    endpoint = "opensearch"
  }
  application {
    name     = juju_application.opensearch.name
    endpoint = "opensearch-client"
  }
}

resource "juju_integration" "self-signed-certificates" {
  model = local.juju_model_name

  application {
    name     = juju_application.opensearch.name
    endpoint = "certificates"
  }
  application {
    name     = juju_application.self_signed_certificates.name
    endpoint = "certificates"
  }
}
