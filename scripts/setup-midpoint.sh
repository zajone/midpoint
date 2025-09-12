#!/bin/bash
set -e

# Configuration - adjust paths and names as needed
NAMESPACE="midpoint"
PV_DIRS=(
  "/mnt/data/data-midpoint-postgres-0"
  "/mnt/data/home-midpoint-0"
)
PV_YAML_PATH="./midpoint/k8s/persistentvolume.yaml"
PVC_YAML_PATH="./midpoint/k8s/persistentvolumeclaim.yaml"
HELM_CHART_PATH="./midpoint"

# 1. Create hostPath directories and set ownership
echo "Creating PersistentVolume directories and setting permissions..."
for dir in "${PV_DIRS[@]}"; do
  if [ ! -d "$dir" ]; then
    sudo mkdir -p "$dir"
    echo "Created directory $dir"
  else
    echo "Directory $dir already exists"
  fi
  sudo chown -R 1000:1000 "$dir"
  echo "Set ownership of $dir to UID 1000:GID 1000"
done

# 2. Create Kubernetes namespace if it doesn't exist
echo "Checking for Kubernetes namespace '$NAMESPACE'..."
if ! kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
  kubectl create namespace "$NAMESPACE"
  echo "Namespace '$NAMESPACE' created."
else
  echo "Namespace '$NAMESPACE' already exists."
fi

# 3. Apply PersistentVolumes and PersistentVolumeClaims
echo "Applying PersistentVolumes..."
kubectl apply -f "$PV_YAML_PATH"

echo "Applying PersistentVolumeClaims..."
kubectl apply -f "$PVC_YAML_PATH"

echo "Setup complete."