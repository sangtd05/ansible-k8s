# Ansible Kubernetes Setup

## 🚀 Tính năng

- ✅ Cài đặt Kubernetes cluster (HA hoặc single master)
- ✅ Hỗ trợ containerd runtime
- ✅ Cài đặt Nginx Ingress Controller
- ✅ Cấu hình Calico CNI
- ✅ Tự động join worker nodes
- ✅ Cài đặt Helm package manager
- ✅ Sample application để test
- ✅ Hỗ trợ Ubuntu/Debian

## 📋 Yêu cầu hệ thống

### Máy chủ
- **OS**: Ubuntu 20.04+ hoặc Debian 11+
- **RAM**: Tối thiểu 2GB (khuyến nghị 4GB+)
- **CPU**: Tối thiểu 2 cores
- **Disk**: Tối thiểu 20GB
- **Network**: Kết nối internet

### Máy điều khiển (Ansible)
- Ansible 2.9+
- Python 3.6+
- SSH access đến tất cả nodes

## 🏗️ Cấu trúc dự án

```
ansible-k8s-setup/
├── ansible.cfg                 # Cấu hình Ansible
├── inventory/
│   └── hosts.yml              # Inventory file
├── group_vars/
│   ├── all.yml                # Biến global
│   ├── k8s_masters.yml        # Biến cho master nodes
│   └── k8s_workers.yml        # Biến cho worker nodes
├── playbooks/
│   ├── 01-prepare-nodes.yml   # Chuẩn bị nodes
│   ├── 02-install-containerd.yml # Cài đặt containerd
│   ├── 03-install-k8s.yml     # Cài đặt Kubernetes
│   ├── 04-init-master.yml     # Khởi tạo master
│   ├── 05-join-workers.yml    # Join worker nodes
│   ├── 06-install-nginx-ingress.yml # Cài đặt Nginx Ingress
│   ├── 07-install-helm.yml    # Cài đặt Helm
│   ├── test-cluster.yml       # Test cluster
│   └── cleanup.yml            # Dọn dẹp cluster
├── templates/
│   ├── kubeadm-config.yaml.j2
│   └── sample-ingress.yaml.j2
├── site.yml                   # Playbook chính
├── requirements.yml           # Ansible dependencies
├── Makefile                   # Commands tiện ích
└── README.md
```

## ⚙️ Cấu hình

### 1. Cập nhật Inventory

Chỉnh sửa file `inventory/hosts.yml` với thông tin máy chủ của bạn:

```yaml
all:
  children:
    k8s_cluster:
      children:
        k8s_masters:
          hosts:
            master-1:
              ansible_host: 192.168.1.10  # IP của master node
              ansible_user: root
        k8s_workers:
          hosts:
            worker-1:
              ansible_host: 192.168.1.20  # IP của worker node
              ansible_user: root
```

### 2. Cấu hình SSH

Đảm bảo bạn có thể SSH vào tất cả nodes:

```bash
# Copy SSH key đến tất cả nodes
ssh-copy-id root@192.168.1.10
ssh-copy-id root@192.168.1.20
```

### 3. Cập nhật biến cấu hình

Chỉnh sửa các file trong `group_vars/` nếu cần:

- `group_vars/all.yml`: Cấu hình chung
- `group_vars/k8s_masters.yml`: Cấu hình master nodes
- `group_vars/k8s_workers.yml`: Cấu hình worker nodes

## 🚀 Triển khai

### Cài đặt dependencies

```bash
# Cài đặt Ansible collections
make install-deps
# hoặc
ansible-galaxy collection install -r requirements.yml
```

### Kiểm tra kết nối

```bash
# Kiểm tra inventory
make check-inventory

# Kiểm tra SSH connectivity
make check-connectivity
```

### Triển khai cluster

```bash
# Triển khai toàn bộ cluster
make deploy

# Hoặc chạy từng bước
make prepare-nodes
make install-containerd
make install-k8s
make install-helm
make init-master
make join-workers
make install-ingress
```

### Test cluster

```bash
# Test cluster functionality
make test-cluster
```

## 🔧 Sử dụng Makefile

```bash
make help                    # Hiển thị tất cả commands
make install-deps           # Cài đặt dependencies
make check-inventory        # Kiểm tra inventory
make check-connectivity     # Kiểm tra SSH connectivity
make deploy                 # Triển khai toàn bộ cluster
make test-cluster          # Test cluster
make clean                 # Dọn dẹp cluster (CẢNH BÁO!)
```

## 📊 Kiểm tra cluster

Sau khi triển khai thành công, bạn có thể kiểm tra:

```bash
# SSH vào master node
ssh root@<master-ip>

# Kiểm tra nodes
kubectl get nodes -o wide

# Kiểm tra pods
kubectl get pods -A

# Kiểm tra ingress controller
kubectl get pods -n ingress-nginx

# Kiểm tra sample application
kubectl get pods -n sample-app
kubectl get ingress -A
```

## 🌐 Truy cập ứng dụng

Sau khi cài đặt, bạn có thể truy cập sample application:

1. **Lấy IP của ingress controller:**
   ```bash
   kubectl get svc -n ingress-nginx ingress-nginx-controller
   ```

2. **Thêm entry vào /etc/hosts:**
   ```
   <ingress-ip> nginx.example.com
   ```

3. **Truy cập ứng dụng:**
   ```
   http://nginx.example.com
   ```

## 🛠️ Troubleshooting

### Lỗi thường gặp

1. **SSH connection failed:**
   ```bash
   # Kiểm tra SSH key
   ssh-add -l
   # Copy key mới
   ssh-copy-id root@<node-ip>
   ```

2. **Kubelet not starting:**
   ```bash
   # Kiểm tra logs
   journalctl -u kubelet -f
   # Restart kubelet
   systemctl restart kubelet
   ```

3. **Pods stuck in Pending:**
   ```bash
   # Kiểm tra node resources
   kubectl describe nodes
   # Kiểm tra CNI
   kubectl get pods -n kube-system
   ```

### Logs hữu ích

```bash
# Kubelet logs
journalctl -u kubelet -f

# Container runtime logs
journalctl -u containerd -f

# Kubernetes API server logs
kubectl logs -n kube-system kube-apiserver-<node-name>
```

## 🧹 Dọn dẹp

**CẢNH BÁO**: Lệnh này sẽ xóa toàn bộ cluster!

```bash
make clean
```

## 📝 Tùy chỉnh

### Thay đổi Kubernetes version

Chỉnh sửa trong `group_vars/all.yml`:

```yaml
kubernetes_version: "1.33.2"
kubelet_version: "1.33.2"
kubectl_version: "1.33.2"
kubeadm_version: "1.33.2"
```

### Thay đổi CNI plugin

Thay đổi Calico sang Flannel hoặc Weave Net trong `group_vars/all.yml`:

```yaml
# Cho Flannel
flannel_version: "0.22.3"
flannel_manifest_url: "https://raw.githubusercontent.com/flannel-io/flannel/v{{ flannel_version }}/Documentation/kube-flannel.yml"
pod_network_cidr: "10.244.0.0/16"

# Cho Calico (mặc định)
calico_version: "3.27.0"
calico_manifest_url: "https://raw.githubusercontent.com/projectcalico/calico/v{{ calico_version }}/manifests/calico.yaml"
pod_network_cidr: "192.168.0.0/16"
```

### Thêm node labels/taints

Chỉnh sửa trong `group_vars/k8s_workers.yml`:

```yaml
worker_labels:
  - "node-role.kubernetes.io/worker="
  - "kubernetes.io/arch={{ ansible_architecture }}"
  - "custom-label=value"
```