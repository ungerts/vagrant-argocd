# swapoff -a
apt-get update
apt-get install -y vim curl wget git skopeo
snap install microk8s --classic
microk8s status --wait-ready
microk8s enable registry storage dns ingress
snap install kubectl --classic
mkdir -p /root/.kube
microk8s config > /root/.kube/config
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
# microk8s kubectl wait -n argocd --timeout=180s --for=condition=ready pod -l app.kubernetes.io/name=argocd-server
# sleep 180
ARGO_CLI_VERSION=$(curl --silent "https://api.github.com/repos/argoproj/argo-cd/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/$ARGO_CLI_VERSION/argocd-linux-amd64
chmod +x /usr/local/bin/argocd
kubectl apply --filename https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
curl -sLO https://github.com/tektoncd/cli/releases/download/v0.15.0/tkn_0.15.0_Linux_x86_64.tar.gz
tar xvzf tkn_0.15.0_Linux_x86_64.tar.gz -C /usr/local/bin/ tkn
echo "Password: $(kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2)"
#    microk8s kubectl port-forward --address localhost,192.168.33.13 svc/argocd-server -n argocd 8080:443