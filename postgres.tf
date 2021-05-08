resource "kubernetes_namespace" "postgres" {
  metadata {
    name = "postgres"
  }
}

resource "random_password" "postgres" {
  length = 32
}

resource "kubernetes_secret" "postgres" {
  metadata {
    name      = "postgres-secret"
    namespace = kubernetes_namespace.postgres.metadata.0.name
  }

  data = {
    "postgresql-password" = random_password.postgres.result
  }
}

resource "helm_release" "postgres" {
  name       = "postgres"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"
  version    = var.postgres_helm_chart_version
  namespace  = kubernetes_namespace.postgres.metadata.0.name

  set {
    name  = "postgresqlUsername"
    value = var.postgres_username
  }

  set {
    name  = "fullnameOverride"
    value = var.postgres_service_name
  }

  set {
    name  = "existingSecret"
    value = kubernetes_secret.postgres.metadata.0.name
  }

  set {
    name  = "service.port"
    value = var.postgres_service_port
  }

  set {
    name  = "persistence.size"
    value = "1Gi"
  }
}
