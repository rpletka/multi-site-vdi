# Configure the VMware NSX-T Provider
provider "nsxt" {
    host = var.nsxIP
    username = var.nsxUser
    password = var.nsxPassword
    allow_unverified_ssl = true
}


resource "nsxt_policy_group" "SharedServices" {
  display_name = "Shared Services"
  description  = "Shared Services Group provisioned by Terraform"
  criteria {
  ipaddress_expression {
      ip_addresses = ["10.1.4.2", "10.2.1.2"]
    }
  }
} 

resource "nsxt_policy_group" "VDI-Desktops" {
  display_name = "VDI Desktops"
  description  = "VDI Desktops Group provisioned by Terraform"
  criteria {
  ipaddress_expression {
      ip_addresses = ["10.100.65.0/24", "10.100.65.0/24"]
    }
  }
} 

resource "nsxt_policy_group" "InternetProxy" {
  display_name = "Internet Proxy"
  description  = "Internet Proxy simulation provisioned by Terraform"
  criteria {
    ipaddress_expression {
      ip_addresses = ["1.0.0.0/8","3.0.0.0/8","4.0.0.0/6", "8.0.0.0/7", "11.0.0.0/8", "11.0.0.0/8", "12.0.0.0/6", "16.0.0.0/4", "32.0.0.0/3", "64.0.0.0/2", "128.0.0.0/3", "160.0.0.0/5", "168.0.0.0/6", "172.0.0.0/12", "172.32.0.0/11", "172.64.0.0/10", "172.128.0.0/9", "173.0.0.0/8", "174.0.0.0/7", "176.0.0.0/4", "192.0.0.0/9", "192.128.0.0/11", "192.160.0.0/13", "192.169.0.0/16", "192.170.0.0/15", "192.172.0.0/14", "192.176.0.0/12", "192.192.0.0/10", "193.0.0.0/8", "194.0.0.0/7", "196.0.0.0/6", "200.0.0.0/5", "208.0.0.0/4"]
    }
  }
}

resource "nsxt_policy_security_policy" "Multisite-VDI" {
  description  = "Policy for multisite VDI deployment"
  display_name = ""
  category = "Environment"
  rule {
    display_name = "Allow Shared Services"
    description  = ""
    action       = "ALLOW"
    ip_version  = "IPV4"
    source_groups = [nsxt_policy_group.VDI-Desktops.path]
    destination_groups = [nsxt_policy_group.SharedServices.path]
    scope = [nsxt_policy_group.VDI-Desktops.path, nsxt_policy_group.SharedServices.path]
  }
   rule {
    display_name = "Allow Internet Proxy Access"
    description  = ""
    action       = "ALLOW"
    ip_version  = "IPV4"
    source_groups = [nsxt_policy_group.VDI-Desktops.path]
    destination_groups = [nsxt_policy_group.InternetProxy.path]
    scope = [nsxt_policy_group.VDI-Desktops.path, nsxt_policy_group.InternetProxy.path]
  }
  rule {
    display_name = "Prevent Lateral Movement"
    description  = ""
    action       = "REJECT"
    ip_version  = "IPV4"
    source_groups = [nsxt_policy_group.VDI-Desktops.path]
    destination_groups = [nsxt_policy_group.VDI-Desktops.path]
    scope = [nsxt_policy_group.VDI-Desktops.path]
  }
}

resource "nsxt_policy_security_policy" "PrivateCloudGaurdrailBlackist" {
  description  = "Private Cloud Default Section provisioned by Terraform"
  display_name = "Private Cloud Default Deny"
  category = "Application"
  sequence_number = 59999
  rule {
    display_name = "Default Deny (Reject)"
    description  = ""
    action       = "REJECT"
    ip_version  = "IPV4"
    destination_groups =  [nsxt_policy_group.VDI-Dekstops.path]
    scope = [nsxt_policy_group.VDI-Dekstops.path]
  }
    rule {
    display_name = "Default Deny (Reject)"
    description  = ""
    action       = "REJECT"
    ip_version  = "IPV4"
    source_groups =  [nsxt_policy_group.VDI-Dekstops.path]
    scope = [nsxt_policy_group.VDI-Dekstops.path]
  }
}
