resource "oci_core_vcn" "genai_vcn" {
  cidr_block     = var.vcn_cidr_block
  compartment_id = var.compartment_ocid
  display_name   = var.vcn_display_name
  dns_label      = var.vcn_dns_label
}

resource "oci_core_internet_gateway" "genai_ig" {
  compartment_id = var.compartment_ocid
  display_name   = "GENAI-LAB-IG"
  vcn_id         = oci_core_vcn.genai_vcn.id
}

resource "oci_core_nat_gateway" "genai_nat" {
  compartment_id = var.compartment_ocid
  display_name   = "GENAI-LAB-NAT"
  vcn_id         = oci_core_vcn.genai_vcn.id
}

data "oci_core_services" "all_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

resource "oci_core_service_gateway" "genai_sg" {
  compartment_id = var.compartment_ocid
  display_name   = "GENAI-LAB-SG"
  services {
    service_id = data.oci_core_services.all_services.services[0].id
  }
  vcn_id         = oci_core_vcn.genai_vcn.id
}

resource "oci_core_route_table" "public_rt" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.genai_vcn.id
  display_name   = "public-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.genai_ig.id
  }
}

resource "oci_core_route_table" "private_rt" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.genai_vcn.id
  display_name   = "private-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.genai_nat.id
  }

  route_rules {
    destination       = data.oci_core_services.all_services.services[0].cidr_block
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.genai_sg.id
  }
}

resource "oci_core_security_list" "public_sl" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.genai_vcn.id
  display_name   = "public-sl"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"
    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"
    tcp_options {
      min = 8888
      max = 8888
    }
  }

  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"
    tcp_options {
      min = 8501
      max = 8501
    }
  }

  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"
    tcp_options {
      min = 1521
      max = 1521
    }
  }
}

resource "oci_core_security_list" "private_sl" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.genai_vcn.id
  display_name   = "private-sl"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  ingress_security_rules {
    protocol = "all"
    source   = var.vcn_cidr_block
  }
}

resource "oci_core_subnet" "public_subnet" {
  cidr_block        = var.public_subnet_cidr_block
  display_name      = "public"
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_vcn.genai_vcn.id
  route_table_id    = oci_core_route_table.public_rt.id
  security_list_ids = [oci_core_security_list.public_sl.id]
  dns_label         = "public"
}

resource "oci_core_subnet" "private_subnet" {
  cidr_block                 = var.private_subnet_cidr_block
  display_name               = "private"
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.genai_vcn.id
  route_table_id             = oci_core_route_table.private_rt.id
  security_list_ids          = [oci_core_security_list.private_sl.id]
  dns_label                  = "private"
  prohibit_public_ip_on_vnic = true
}
