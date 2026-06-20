# Azure Portal Deployment Flow – BlueSky Intranet VNet Lab

## 1. Create Resource Group
1. In the Azure Portal, go to **Resource groups** → **Create**.
2. Set:
   - Name: `rg-bluesky`
   - Region: `East US`
3. Click **Review + create** → **Create**.

## 2. Create Virtual Network and Subnets
1. Go to **Virtual networks** → **Create**.
2. Basics:
   - Resource group: `rg-bluesky`
   - Name: `vnet-bluesky`
   - Region: `East US`
3. IP addresses:
   - Address space: `10.0.0.0/16`
4. Subnets:
   - `subnet-web` → `10.0.1.0/24`
   - `subnet-mgmt` → `10.0.2.0/24`
   - `AzureBastionSubnet` → `10.0.3.0/27`
5. Create the VNet.

## 3. Create NSGs and Associate
1. Go to **Network security groups** → **Create**.
2. Create `nsg-web` in `rg-bluesky`.
   - Add rules to allow HTTP (80) and SSH (22) from appropriate sources.
3. Create `nsg-mgmt` in `rg-bluesky` (default rules are fine for Bastion).
4. Associate:
   - `nsg-web` → `subnet-web`
   - `nsg-mgmt` → `subnet-mgmt`

## 4. Create Storage Account
1. Go to **Storage accounts** → **Create**.
2. Set:
   - Resource group: `rg-bluesky`
   - Name: `stblueskylogs`
   - Region: `East US`
   - Performance: Standard
3. Create the storage account (used for boot diagnostics and logs).

## 5. Deploy Linux VM
1. Go to **Virtual machines** → **Create**.
2. Basics:
   - Resource group: `rg-bluesky`
   - Name: `vm-web01`
   - Region: `East US`
   - Image: Ubuntu Server 22.04 LTS
   - Size: small (e.g., B1s/B2s)
3. Networking:
   - VNet: `vnet-bluesky`
   - Subnet: `subnet-web`
   - NSG: use `nsg-web` or subnet association
4. Management:
   - Enable boot diagnostics using `stblueskylogs`.
5. Create the VM.

## 6. Install NGINX on VM
1. Connect via SSH (Bastion later, or temporary public IP).
2. Run:
   ```bash
   sudo apt update
   sudo apt install -y nginx
