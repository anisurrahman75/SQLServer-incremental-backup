#!/bin/bash
debug() {
    echo "[DEBUG] $1"
}

echo "127.0.0.1       backup.local" >> /etc/hosts

openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /incremental-backup/certs/ca.key -out /incremental-backup/certs/ca.crt -subj "/O=kubedb"
if [ $? -ne 0 ]; then
    debug "Failed to generate CA certificate and key"
    exit 1
fi

cp /incremental-backup/certs/ca.crt /usr/local/share/ca-certificates/test-ca.crt
if [ $? -ne 0 ]; then
    debug "Failed to copy CA certificate to /usr/local/share/ca-certificates"
    exit 1
fi

mkdir -p /var/opt/mssql/security/ca-certificates
cp /incremental-backup/certs/ca.crt /var/opt/mssql/security/ca-certificates/ca.crt
if [ $? -ne 0 ]; then
    debug "Failed to copy CA certificate to /var/opt/mssql/security/ca-certificates"
    exit 1
fi

update-ca-certificates
if [ $? -ne 0 ]; then
    debug "Failed to update CA certificates"
    exit 1
fi

debug "Creating subjectAltName file altsubj.ext"
echo "subjectAltName=IP:127.0.0.1,DNS:backup.local" > /incremental-backup/certs/altsubj.ext

openssl req -newkey rsa:2048 -nodes -keyout /incremental-backup/certs/server.key -out /incremental-backup/certs/server.csr -subj "/CN=backup.local"
if [ $? -ne 0 ]; then
    debug "Failed to generate server key and CSR"
    exit 1
fi

# Generate server certificate
debug "Generating server certificate"
openssl x509 -req -in /incremental-backup/certs/server.csr -CA /incremental-backup/certs/ca.crt -CAkey /incremental-backup/certs/ca.key -CAcreateserial -out /incremental-backup/certs/server.crt -days 365 -extfile /incremental-backup/certs/altsubj.ext
if [ $? -ne 0 ]; then
    debug "Failed to generate server certificate"
    exit 1
fi

debug "Certificate setup completed successfully"
