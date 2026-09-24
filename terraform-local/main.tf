terraform {
  required_providers {
    kind = {
      source  = "tehcyx/kind"
      version = "~> 0.11"
    }
  }
}

provider "kind" {}

resource "kind_cluster" "online_boutique" {
  name = "online-boutique"
}
