# homelab

[Management UI](https://192.168.100.9:8006)

## Hardware

- Unifi USG
- Beelink SER5 Max Ryzen7 5800H, 32GB Memory

## USG

### Network Config

| Network    | IP Range         | DHCP                             | VLAN-ID | DMZ? |
|------------|------------------|----------------------------------|---------|------|
| jupiter-hl | 192.168.100.1/24 | 192.168.100.10 - 192.168.100.254 | 100     | (x)  |
| europa-hl  | 192.168.111.1/24 | 192.168.111.10 - 192.168.111.254 | 111     | (/)  |

#### Firewall Rules

To be written

## Proxmox - Jupiter

The IP Address and VM ID relate to each other. Just remove the last digit (should always be zero)

| VM ID | IP              |
|-------|-----------------|
| 100   | 192.168.XXX.10  |
| 250   | 192.168.XXX.25  |
| 990   | 192.168.XXX.99  |
| 1000  | 192.168.XXX.100 |
| 2500  | 192.168.XXX.250 |


#### Network Config

After installation, keep the Beelink Device plugged into the screen, login with root and edit
the `/etc/network/interfaces` file to have the following content.

```
auto vmbr0
iface vmbr0 inet manual
        bridge-ports enp1s0
        bridge-stp off
        bridge-fd 0
        bridge-vlan-aware yes
        bridge-vids 2-4094

auto vmbr0.100
iface vmbr0.100 inet static
        address 192.168.100.9/24
        gateway 192.168.100.1

iface wlo1 inet manual
```

Restart device `reboot`

#### Locale

Fix locale errors on the host proxmox

```
locale-gen en_US.UTF-8
echo "export LC_ALL=en_US.UTF-8" >> ~/.bashrc
echo "export LANG=en_US.UTF-8" >> ~/.bashrc
echo "export LANGUAGE=en_US.UTF-8" >> ~/.bashrc
```

#### SSH Config

Add public key to `/root/.ssh/authorized_keys`

```
curl https://github.com/zogot.keys >> ~/.ssh/authorized_keys
```

Further improvement would be my own user, prevent root to login unless from own machine. Will need to check all works
with VMs when doing this.

#### User Config

Terraform uses an API Token to create the rest of the setup. For this, we need to manually create the user, role
and token.

```
pveum user add terraform@pve
pveum role add Terraform -privs "Datastore.Allocate Datastore.AllocateSpace Datastore.AllocateTemplate Datastore.Audit Pool.Allocate Sys.Audit Sys.Console Sys.Modify SDN.Use VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Migrate VM.Monitor VM.PowerMgmt User.Modify"
pveum aclmod / -user terraform@pve -role Terraform
pveum user token add terraform@pve provider --privsep=0
```

Save token in 1password under name: "Terraform API Key - Jupiter Homelab"

#### Enable Snippets

```
pvesm set local --content rootdir,vztmpl,backup,iso,snippets
```

#### Updates
```
echo "deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription" > /etc/apt/sources.list.d/pve-no-subscription.list
echo "deb http://download.proxmox.com/debian/ceph-reef bookworm no-subscription" > /etc/apt/sources.list.d/ceph-no-subscription.list
rm /etc/apt/sources.list.d/pve-enterprise.list
rm /etc/apt/sources.list.d/ceph.list
apt update
apt upgrade
apt autoremove
```

Restart with `reboot`

## Terraform

From here on, all commands are from within the `terraform` directory.

Since Jetbrains IDEs dont support all schemas for Terraform providers, we will generate our own from the installed 
providers.

This installs it to your home directory, so only need to run this once per development machine.

```
terraform providers schema -json > ~/.terraform.d/metadata-repo/terraform/model/providers/homelab.json
```

Restart IDE after running this command

Next is to get the modules and providers

```
terraform init
terraform get
```

This setup is influenced heavily by this great article here: https://blog.stonegarden.dev/articles/2024/03/proxmox-k8s-with-cilium

The list of changes includes:

* Updating Debian Instance and SHA from here: https://cloud.debian.org/images/cloud/bookworm/ used in [images.tf](terraform/images.tf)
* Change from ZFS to LVM storage
* Updated VM IDs and Network Information to be inline with my setup
* Supported defining additional workers and their basic configuration
* Changed Timezone
* Refactored variable names in tftpl files to all consistently be underscores
* Changed BIOS and Machine Type since I don't need PCIE Passthrough
* Updated Hostnames and Resource names to be more inline with my own naming preferences
* Changed output directory and filenames to work more with this 'monorepo' style approach


### State

Terraform State is stored in the Terraform Cloud under a Free Organization.

When creating the Workspace on Terraform Cloud, make sure to change the configuration under the _Settings_ menu
item under **Execution Mode** to _Local (custom)_

This is because you run this locally initially, and then later it will run from a self-hosted GitHub Action Runner.

## PiHole

I decided to just start with a single PiHole instance and not yet getting Unbound up. I also wanted to run it with LXC
instead of a VM.

There wasn't a huge amount of reference material in relation to LXC issues that just resulted in answers that aren't 
great for automation. In the end resulted in having to use provisioners in terraform, there is support for Cloud-Init
for LXC but not yet in Proxmox.

That would be a nice upgrade.

### Router Firewall Rules

Since the PiHole is in VLAN 100, and some of the other networks I have are zoned off from other networks, for example
my Internet of Things network.

This will also come with usage of the europa network for public available vms.

This is the configuration in simple terms:

* Type: LAN In
* Name: Any to PiHole DNS
* Action: Accept
* Protocol: All
  * Before Predefined
* Source Type: Port/IP Group
* Address Group: Any
* Port Group: Any
* Destination Type: Port/IP Group
* Address Group: pihole
  * 192.168.100.80
* Port Group: dns
  * 53