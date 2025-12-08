#!/bin/bash
# Generate self-signed certificate for OFBiz

mkdir -p certs
cd certs

# Generate private key and certificate
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes \
  -subj "/C=US/ST=State/L=City/O=Development/CN=localhost" \
  -addext "subjectAltName=DNS:localhost,IP:127.0.0.1"

# Convert to PKCS12 format (Java keystore)
openssl pkcs12 -export -in cert.pem -inkey key.pem -out ofbiz.p12 -name ofbiz -passout pass:changeit

echo "Certificate generated in certs/ directory"
echo "Import cert.pem to your Windows Trusted Root Certification Authorities to avoid browser warnings"
