Windocks SQL proxy

The Windocks SQL proxy delivers Windows SQL Server containers with database clones to a cluster. The proxy:
- Creates a Windows SQL Server container on a designated external machine that already has Windocks (cloud or on-prem)
- Clones terabyte sized SQL Server databases in seconds and delivers them to the container
- Proxies SQL traffic from the client applications (users, .Net apps, Sql Server Management Studio, NodeJs apps etc) to the Windocks container
- Enables the client applications to work on the cloned databases (usually production database clones) 
- Deletes the Windocks SQL Server container when the SQL proxy pod / container is deleted

Pre-requisites
1. Windocks installed on a machine accessible to the cluster 
2. For TLS connections, the required TLS setup on the Windocks machine and an SSL certificate and key for the proxy

Steps

1. Enter the values for proxy image name/tag and  environment variables (Windocks host ip, Windocks server port, etc. ). Use the default values where provided

2. Create the auth secret: create secret generic proxy-secrets --from-literal=WINDOCKS_REQUIRED_USERNAME='windocks-api-username' --from-literal=WINDOCKS_REQUIRED_PASSWORD='windocks-api-password' --from-literal=WINDOCKS_REQUIRED_CONTAINER_SAPASSWORD='sa-password-to-set-for-windocks-container'

3. For TLS: Create a secret in a file with tls.key and tls.crt, both of which are mounted as files into the container. Separate coniguration is required on the Windocks server

4. Deploy the app and use SQL Server Management Studio or Azure Management Studio to connect to the <Windocks=host-IP>,3087 using SQL auth: sa and the password above

Email support@windocks.com for issues