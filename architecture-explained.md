# Architecture Explained – BlueSky Intranet VNet Lab

## Overview
This lab models a small, secure intranet environment in Azure. It uses a virtual network with segmented subnets, a Linux web server, a public load balancer, Azure Bastion for secure administration, and a storage account for diagnostics.

## Virtual Network (vnet-bluesky)
- Address space: `10.0.0.0/16`
- Purpose: Provides an isolated, private network boundary for all resources.
- Why it matters: Core AZ-104 skill; foundation for secure cloud networking.

## Subnets
### subnet-web (`10.0.1.0/24`)
- Hosts the web VM and is associated with `nsg-web`.
- Purpose: Isolates front-end workloads and controls inbound HTTP/SSH traffic.

### subnet-mgmt (`10.0.2.0/24`)
- Reserved for management-related resources.
- Purpose: Demonstrates separation of management plane from data plane.

### AzureBastionSubnet (`10.0.3.0/27`)
- Required subnet for Azure Bastion.
- Purpose: Provides a dedicated, secure zone for Bastion to operate.

## Network Security Groups (NSGs)
### nsg-web
- Allows HTTP (80) and SSH (22) from defined sources.
- Purpose: Controls access to the web subnet and VM.

### nsg-mgmt
- Uses default rules suitable for Bastion-based access.
- Purpose: Protects management subnet while relying on Bastion for secure entry.

## Azure Virtual Machine (vm-web01)
- OS: Ubuntu Server 22.04 LTS
- Role: Hosts NGINX web server.
- Purpose: Represents a typical application server in a corporate intranet.

## NGINX Web Server
- Installed via package manager.
- Purpose: Provides a simple, testable web endpoint.
- Why NGINX: Lightweight, widely used, and easy to configure.

## Public Load Balancer (lb-web)
- Frontend IP: `pip-lb-web`
- Backend pool: `vm-web01`
- Health probe: HTTP on port 80.
- Purpose: Distributes traffic and provides a single public entry point.
- Value: Demonstrates high availability and traffic management concepts.

## Azure Bastion (bastion-bluesky)
- Subnet: `AzureBastionSubnet`
- Public IP: `pip-bastion`
- Purpose: Enables secure RDP/SSH over TLS directly in the portal.
- Value: Eliminates the need to expose SSH/RDP ports to the internet.

## Storage Account (stblueskylogs)
- Role: Stores boot diagnostics and logs.
- Purpose: Centralizes diagnostic data for troubleshooting and monitoring.
- Value: Reinforces observability and operational readiness.

## Public IPs
- `pip-lb-web`: Entry point for web traffic.
- `pip-bastion`: Entry point for secure admin access.
- Purpose: Controlled exposure of services to the internet.

## Bicep IaC
- Template: `iac/bluesky-main.bicep`
- Purpose: Declaratively defines the environment for repeatable deployments.
- Value: Demonstrates modern Azure automation and infrastructure as code practices.

## Design Principles
- Segmentation: Separate subnets for web, management, and Bastion.
- Least privilege: NSGs restrict traffic to necessary ports.
- Secure access: Bastion instead of direct SSH/RDP exposure.
- Observability: Storage account for diagnostics.
- Repeatability: Bicep template for consistent deployments.
