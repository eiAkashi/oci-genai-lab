# --- For provider (use in provider.tf) ---
variable "user_ocid" {
  default=""
}
variable "fingerprint" {
  default = ""
}
variable "tenancy_ocid" {
  description = "OCI tenancy's OCID"
  default=""
}
variable "private_key_path" {
  default = ""
}
variable "region" {
  default = "eu-frankfurt-1"
}
variable "compartment_ocid" {
  default=""
}
variable "availability_domain" {
  description = "Availability domain (AD) name. If not provided, the first AD found will be used."
  default     = ""
}

variable "shape" {
  description = "Instance shape"
  default     = "VM.Standard.E5.Flex"
}

variable "instance_ocpus" {
  default = 2
}

variable "instance_memory_in_gbs" {
  default = 24
}


variable "infra_compartment_name" {
  description = "Name for the core infrastructure compartment (network, compute, etc.)"
  default     = "infra_compartment"
}

variable "rag_compartment_name" {
  description = "Name for the RAG AI application compartment"
  default     = "rag_app_compartment"
}

variable "oke_compartment_name" {
  description = "Name for the Kubernetes (OKE) compartment"
  default     = "oke_app_compartment"
}

variable "vcn_display_name" {
  description = "Display name for the VCN"
  default     = "GENAI-LAB-VCN"
}

variable "vcn_cidr_block" {
  description = "IPv4 CIDR block for the VCN"
  default     = "10.7.0.0/16"
}

variable "public_subnet_cidr_block" {
  description = "IPv4 CIDR block for the public subnet"
  default     = "10.7.0.0/24"
}

variable "private_subnet_cidr_block" {
  description = "IPv4 CIDR block for the private subnet"
  default     = "10.7.100.0/24"
}

variable "vcn_dns_label" {
  description = "DNS label for the VCN"
  default     = "genailabvcn"
}