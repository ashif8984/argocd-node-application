#!/usr/bin/env bash

set -e

# Prompt user for GitHub Token (hidden input for security)
read -s -p "Enter your GitHub Personal Access Token (PAT): " GITHUB_TOKEN
echo ""

if [ -z "$GITHUB_TOKEN" ]; then
  echo "Error: GitHub Token cannot be empty."
  exit 1
fi

# Prompt for repository (press enter to use default)
read -p "Enter GitHub Repository [ashif8984/argocd-node-application]: " GITHUB_REPO
GITHUB_REPO=${GITHUB_REPO:-"ashif8984/argocd-node-application"}

NAMESPACE="actions-runner-system"

# 1. Install cert-manager
echo "Installing cert-manager..."
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.8.2/cert-manager.yaml

echo "Waiting for cert-manager pods to be ready..."
kubectl wait --namespace cert-manager --for=condition=ready pod --selector=app.kubernetes.io/instance=cert-manager --timeout=120s

# 2. Add or update Helm Repo (Conditional Check)
echo "Checking Helm repository..."
if helm repo list 2>/dev/null | grep -q "^actions-runner-controller"; then
  echo "Repo 'actions-runner-controller' already exists. Updating..."
  helm repo update actions-runner-controller
else
  echo "Adding 'actions-runner-controller' repo..."
  helm repo add actions-runner-controller https://actions-runner-controller.github.io/actions-runner-controller
  helm repo update
fi

# 3. Install Actions Runner Controller
echo "Deploying Actions Runner Controller..."
helm upgrade --install actions-runner-controller actions-runner-controller/actions-runner-controller \
  --namespace "$NAMESPACE" \
  --create-namespace \
  --set=authSecret.create=true \
  --set=authSecret.github_token="$GITHUB_TOKEN" \
  --wait

# 4. Deploy Runner Deployment
echo "Deploying Self-Hosted Runner for $GITHUB_REPO..."
cat <<EOF | kubectl apply -f -
apiVersion: actions.summerwind.dev/v1alpha1
kind: RunnerDeployment
metadata:
  name: self-hosted-runner
  namespace: ${NAMESPACE}
spec:
  replicas: 1
  template:
    spec:
      repository: ${GITHUB_REPO}
EOF

# 5. Verify Pods and Runners
echo "Fetching pod status..."
kubectl get pods -n "$NAMESPACE"

echo "Fetching runner status..."
sleep 5
kubectl get runners -n "$NAMESPACE" || true