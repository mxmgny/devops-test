#
# Outputs
#

locals {
  config_map_aws_auth = <<CONFIGMAPAWSAUTH


apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.demo-node.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
CONFIGMAPAWSAUTH

  kubeconfig = <<KUBECONFIG


apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.demo.endpoint}
    certificate-authority-data: ${aws_eks_cluster.demo.certificate_authority.0.data}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "${var.cluster-name}"
KUBECONFIG
}
######


locals {
  fluentd = <<FLUENTD



apiVersion: extensions/v1beta1
kind: DaemonSet
metadata:
  labels:
    k8s-app: fluentd-logging
    kubernetes.io/cluster-service: "true"
  name: fluentd-elasticsearch
  namespace: kube-system
spec:
  selector:
    matchLabels:
      k8s-app: fluentd-logging
      kubernetes.io/cluster-service: "true"
  template:
    metadata:
      annotations:
        scheduler.alpha.kubernetes.io/critical-pod: ""
      creationTimestamp: null
      labels:
        k8s-app: fluentd-logging
        kubernetes.io/cluster-service: "true"
      name: fluentd-elasticsearch
      namespace: kube-system
    spec:
      containers:
      - env:
        - name: AWS_REGION
          value: ${var.zone}
        - name: AWS_ELASTICSEARCH_URL
          value: ${module.es.endpoint}
        - name: AWS_ACCESS_KEY_ID
          value: ${var.access_key_id}
        - name: AWS_SECRET_ACCESS_KEY
          value: ${var.secret_access_key}
        image: cheungpat/fluentd-elasticsearch-aws:1.22
        imagePullPolicy: IfNotPresent
        name: fluentd-elasticsearch
        resources:
          limits:
            memory: 500Mi
          requests:
            cpu: 100m
            memory: 200Mi
        volumeMounts:
        - mountPath: /var/log
          name: varlog
        - mountPath: /var/lib/docker/containers
          name: varlibdockercontainers
          readOnly: true
      restartPolicy: Always
      tolerations:
      - key: node-role.kubernetes.io/master
        effect: NoSchedule
      volumes:
      - hostPath:
          path: /var/log
        name: varlog
      - hostPath:
          path: /var/lib/docker/containers
        name: varlibdockercontainers
FLUENTD
}

output "fluendt_deployment" {
  value = local.fluentd
}

output "config_map_aws_auth" {
  value = local.config_map_aws_auth
}

output "kubeconfig" {
  value = local.kubeconfig
}
