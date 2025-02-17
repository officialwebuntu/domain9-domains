#!/bin/bash

# Ensure the YAML file is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <path_to_yaml_file>"
    exit 1
fi

YAML_FILE="$1"

# Check if the file exists
if [ ! -f "$YAML_FILE" ]; then
    echo "Error: File '$YAML_FILE' not found!"
    exit 1
fi

# Parse the YAML file using 'yq' (ensure 'yq' is installed)
DOMAIN=$(yq eval '.domain' "$YAML_FILE")
NAME=$(yq eval '.registrant.name' "$YAML_FILE")
EMAIL=$(yq eval '.registrant.email' "$YAML_FILE")
DNS_A=$(yq eval '.dns[] | select(.type == "A") | .value' "$YAML_FILE")
DNS_MX=$(yq eval '.dns[] | select(.type == "MX") | .value' "$YAML_FILE")

# Check if necessary values are found
if [[ -z "$DOMAIN" || -z "$DNS_A" || -z "$DNS_MX" || -z "$NAME" || -z "$EMAIL" ]]; then
    echo "Error: Missing required fields in the YAML file."
    exit 1
fi

# Save domain details to the database
sqlite3 registrar.db <<EOF
INSERT INTO domains (domain_name, registrant_name, registrant_email, dns_records)
VALUES ('$DOMAIN', '$NAME', '$EMAIL', '{"A": "$DNS_A", "MX": "$DNS_MX"}');
EOF

# Configure DNS records (simulate the actual creation)
echo "Creating DNS A record for $DOMAIN -> $DNS_A"
echo "Creating DNS MX record for $DOMAIN -> $DNS_MX"

# Add to DNS zone files (this part would depend on your DNS server configuration)
echo "$DOMAIN. IN A $DNS_A" >> /etc/bind/db.example.tld
echo "$DOMAIN. IN MX 10 $DNS_MX" >> /etc/bind/db.example.tld

# Reload DNS server to apply changes
sudo systemctl reload bind9

echo "Domain $DOMAIN registered and DNS records configured."
