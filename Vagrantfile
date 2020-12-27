# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-20.04"
  config.vm.hostname = "argocd"
  config.vm.define "argocd"
  config.vm.network "private_network", ip: "192.168.33.13"
#  config.vm.network "forwarded_port", guest: 8080, host: 8080
  config.vm.provider "virtualbox" do |vb|
    vb.name = "argocd"
    vb.memory = "6000"
    vb.cpus = 2
  end
  config.vm.provision "shell", inline: <<-SHELL
    cd /vagrant
    # bash install.sh
	snap install microk8s --classic
	microk8s status --wait-ready
	microk8s enable dns
	microk8s kubectl create namespace argocd
	microk8s kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
	microk8s kubectl wait --timeout=180s --for=condition=ready pod -l app.kubernetes.io/name=argocd-server
	microk8s kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
	microk8s kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2
#    microk8s kubectl port-forward --address localhost,192.168.33.13 svc/argocd-server -n argocd 8080:443
  SHELL
end