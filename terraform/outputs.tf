output "instance_public_ip" {
  value = oci_core_instance.gen_ai_instance.public_ip
}

output "instance_id" {
  value = oci_core_instance.gen_ai_instance.id
}
