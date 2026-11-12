# Fill ansible inventory for Kubespray
resource "local_file" "inventory" {
  content  = <<-XYZ
[kube_control_plane]
${module.control_planes["control-plane-01"].hostname} ansible_host=${module.control_planes["control-plane-01"].private_ip} ip=${module.control_planes["control-plane-01"].private_ip} etcd_member_name=etcd1

[etcd:children]
kube_control_plane

[kube_node]
${module.workers["worker-01"].hostname} ansible_host=${module.workers["worker-01"].private_ip} ip=${module.workers["worker-01"].private_ip}
${module.workers["worker-02"].hostname} ansible_host=${module.workers["worker-02"].private_ip} ip=${module.workers["worker-02"].private_ip}

[all:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/id_ed25519
ansible_python_interpreter=/usr/bin/python3

ansible_ssh_common_args='-o ProxyJump=ubuntu@${module.bastion.public_ip} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
XYZ
  filename = "../../ansible/kubespray/inventory/mycluster/inventory.ini"
}

 resource "terraform_data" "ansible_config" {
  triggers_replace = [
    sha256(local_file.inventory.content)
  ]

  depends_on = [
    module.bastion,
    module.workers,
    module.control_planes,
    local_file.inventory
  ]

  provisioner "local-exec" {
    working_dir = "/home/sadmin/netology-hw/diploma/ansible/kubespray"

    command = "ansible-playbook -i inventory/mycluster/inventory.ini -b -v cluster.yml"
  }
}