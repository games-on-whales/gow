data "template_cloudinit_config" "config" {
  gzip = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content = file("cloud-init.yml")
  }

  part {
    content_type = "text/cloud-config"

    # JSON is a subset of YAML, so cloud-init should
    # still accept this even though it's jsonencode.
    content = jsonencode({
      write_files = [
        {
          encoding = "b64"
          content = filebase64("${path.module}/../docker-compose.yml")
          path = "/tmp/gow/docker-compose.yml"
          owner = "ubuntu:ubuntu"
          permissions = "0744"
        },
        {
          encoding = "b64"
          content = filebase64("${path.module}/../.env")
          path = "/tmp/gow/.env"
          owner = "ubuntu:ubuntu"
          permissions = "0744"
        }
      ]
    })
  }
}