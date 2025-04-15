#!/bin/bash

set -e

echo "Updating Helm repositories..."
helm repo add argo https://argoproj.github.io/argo-helm || true
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts || true
helm repo add grafana https://grafana.github.io/helm-charts || true
helm repo update

echo "Creating namespaces (if not exist)..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

echo "Installing or upgrading ArgoCD..."
helm upgrade --install argocd argo/argo-cd -n argocd --set server.service.type=NodePort

echo "Installing or upgrading Prometheus..."
helm upgrade --install prometheus prometheus-community/prometheus -n monitoring --set server.service.type=NodePort

echo "Installing or upgrading Grafana..."
helm upgrade --install grafana grafana/grafana -n monitoring --set service.type=NodePort --set adminPassword='admin' --set persistence.enabled=false

echo "Infrastructure setup complete."
