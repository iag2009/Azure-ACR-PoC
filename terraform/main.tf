resource "random_password" "random_passwords" {
  length      = 16
  special     = false
  min_upper   = 2
  min_lower   = 2
  min_numeric = 2
}

resource "time_sleep" "wait_15_seconds_shared" {
  create_duration = "15s"
}
