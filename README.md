# vagrantinit-examples

This is a repository to store Vagrantinit files examples I use sometimes.

All examples are are using Linux + libvirt. No virtualbox here.

# Setup

- Fedora distribution.

- Enviroment variable:
```
export VAGRANT_PREFERRED_PROVIDERS=libvirt
export VAGRANT_DEFAULT_PROVIDER=libvirt
```

- Installation:
```
# dnf install @virtualization libvirt-devel vagrant vagrant-libvirt vagrant-libvirt-doc \
vagrant-sshfs vagrant-cachier
```
