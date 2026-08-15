
#!/bin/bash

# ==========================================================
# Argo CD Installation Script
# ==========================================================

ARGO_NAMESPACE="argocd"
ARGO_REPO_NAME="argo"
ARGO_REPO_URL="https://argoproj.github.io/argo-helm"

# ----------------------------------------------------------
# 1. Check prerequisites
# ----------------------------------------------------------

echo "Checking prerequisites..."

if ! command -v helm &> /dev/null; then
    echo "ERROR: Helm is not installed."
    exit 1
fi

if ! command -v kubectl &> /dev/null; then
    echo "ERROR: kubectl is not installed."
    exit 1
fi

echo "Helm and kubectl are available."

# ----------------------------------------------------------
# 2. Check Kubernetes cluster
# ----------------------------------------------------------

echo "Checking Kubernetes cluster..."

if ! kubectl cluster-info &> /dev/null; then
    echo "ERROR: Kubernetes cluster is not accessible."
    exit 1
fi

echo "Kubernetes cluster is accessible."

# ----------------------------------------------------------
# 3. Check if Argo Helm repo already exists
# ----------------------------------------------------------

echo "Checking Argo Helm repository..."

if helm repo list | grep -q "^${ARGO_REPO_NAME}[[:space:]]"; then

    echo "Argo Helm repository already exists."
    echo "Skipping helm repo add."

else

    echo "Argo Helm repository not found."
    echo "Adding Argo Helm repository..."

    if ! helm repo add "$ARGO_REPO_NAME" "$ARGO_REPO_URL"; then
        echo "ERROR: Failed to add Argo Helm repository."
        exit 1
    fi

    echo "Argo Helm repository added."

fi

# ----------------------------------------------------------
# 4. Update Helm repositories
# ----------------------------------------------------------

echo "Updating Helm repositories..."

if ! helm repo update; then
    echo "ERROR: Failed to update Helm repositories."
    exit 1
fi

# ----------------------------------------------------------
# 5. Create directory structure
# ----------------------------------------------------------

echo "Creating directory structure..."

mkdir -p charts/argocd

cd charts/argocd || exit 1

# ----------------------------------------------------------
# 6. Create values.yaml
# ----------------------------------------------------------

echo "Creating values-argo.yaml..."

cat > values-argo.yaml <<EOF
redis-ha:
  enabled: false

controller:
  replicas: 1

server:
  replicas: 1

repoServer:
  replicas: 1

applicationSet:
  replicas: 1

global:
  domain: argocd.example.com

certificate:
  enabled: true

server:
  ingress:
    enabled: true
    ingressClassName: nginx
    annotations:
      nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
    tls: true
EOF

echo "values-argo.yaml created."

# ----------------------------------------------------------
# 7. Create namespace
# ----------------------------------------------------------

echo "Checking argocd namespace..."

if kubectl get namespace "$ARGO_NAMESPACE" &> /dev/null; then

    echo "Namespace $ARGO_NAMESPACE already exists."

else

    echo "Creating namespace $ARGO_NAMESPACE..."

    if ! kubectl create namespace "$ARGO_NAMESPACE"; then
        echo "ERROR: Failed to create namespace."
        exit 1
    fi

fi

# ----------------------------------------------------------
# 8. Install Argo CD
# ----------------------------------------------------------

echo "Installing Argo CD..."

if ! helm upgrade --install argocd \
    argo/argo-cd \
    --namespace "$ARGO_NAMESPACE" \
    --values values-argo.yaml \
    --wait; then

    echo "ERROR: Argo CD installation failed."
    exit 1
fi

echo "Argo CD installed successfully."

# ----------------------------------------------------------
# 9. Validate installation
# ----------------------------------------------------------

echo ""
echo "=========================================="
echo "Argo CD Installation Validation"
echo "=========================================="

echo ""
echo "Namespaces:"
kubectl get ns

echo ""
echo "Argo CD Pods:"
kubectl get pods -n argocd

echo ""
echo "Argo CD Services:"
kubectl get svc -n argocd

echo ""
echo "Argo CD Ingress:"
kubectl get ingress -n argocd

# ----------------------------------------------------------
# 10. Get Argo CD admin password
# ----------------------------------------------------------

echo ""
echo "=========================================="
echo "Argo CD Admin Credentials"
echo "=========================================="

if kubectl get secret argocd-initial-admin-secret \
    -n argocd &> /dev/null; then

    echo "Username: admin"

    echo -n "Password: "

    kubectl -n argocd get secret \
        argocd-initial-admin-secret \
        -o jsonpath="{.data.password}" \
        | base64 -d

    echo ""

else

    echo "WARNING: Argo CD initial admin secret not found."

fi

# ----------------------------------------------------------
# 11. Access Argo CD locally
# ----------------------------------------------------------

echo ""
echo "=========================================="
echo "Access Argo CD"
echo "=========================================="

echo ""
echo "Run the following command in another terminal:"

echo ""
echo "kubectl port-forward svc/argocd-server -n argocd 8080:443"

echo ""
echo "Then open:"
echo "https://localhost:8080"

echo ""
echo "=========================================="
echo "Argo CD setup completed!"
echo "=========================================="

