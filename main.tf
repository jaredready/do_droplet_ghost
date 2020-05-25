variable do_api_token {}

provider digitalocean {
  token = var.do_api_token
}

data digitalocean_ssh_key jaredready {
  name = "jaredready@Jareds-MacBook-Pro.local"
}

resource digitalocean_droplet ghost { 
  image = "ghost-18-04"
  name = "prod-ghost-blog-nyc1"
  region = "nyc1"
  size = "s-1vcpu-1gb"
  ipv6 = true
  monitoring = true
  ssh_keys = [data.digitalocean_ssh_key.jaredready.id]

  tags = ["prod"]
}

resource digitalocean_firewall web {
  name = "prod-web"

  droplet_ids = [digitalocean_droplet.ghost.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["99.121.106.199/32"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

output droplet_ip_address {
  value = digitalocean_droplet.ghost.ipv4_address
}
