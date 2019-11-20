# JFrog Artifactory Reverse Proxy Settings using Nginx

#### Reverse Proxy
*   To use Artifactory as docker registry it's mandatory to use Reverse Proxy.
*   Artifactory provides a Reverse Proxy Configuration Generator screen in which you can fill in a set of fields to generate 
the required configuration snippet which you can then download and install directly in the corresponding directory of your reverse proxy server.   
*   To learn about configuring NGINX or Apache for reverse proxy refer to documentation provided on [JFrog wiki](https://www.jfrog.com/confluence/display/RTF/Configuring+a+Reverse+Proxy)
*   By default Artifactory helm chart uses Nginx for reverse proxy and load balancing.
  
**Note**: Nginx image distributed with Artifactory helm chart is custom image managed and maintained by JFrog.  
  
####  Features of Artifactory Nginx
*   Provides default configuration with self signed SSL certificate generated on each helm install/upgrade.
*   Persist configuration and SSL certificate in `/var/opt/jfrog/nginx` directory
  
#### Changing the default Artifactory nginx conf
Use a values.yaml file for changing the value of nginx.mainConf or nginx.artifactoryConf
These configuration will be mounted to the nginx container using a configmap.
For example:
1. Create a values file `nginx-values.yaml` with the following values:
```yaml
nginx:
  artifactoryConf: |
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;
    ssl_certificate  {{ .Values.nginx.persistence.mountPath }}/ssl/tls.crt;
    ssl_certificate_key  {{ .Values.nginx.persistence.mountPath }}/ssl/tls.key;
    ssl_session_cache shared:SSL:1m;
    ssl_prefer_server_ciphers   on;
    ## server configuration
    server {
      listen {{ .Values.nginx.internalPortHttps }} ssl;
      listen {{ .Values.nginx.internalPortHttp }} ;
      ## Change to you DNS name you use to access Artifactory 
      server_name ~(?<repo>.+)\.{{ include "artifactory.fullname" . }} {{ include "artifactory.fullname" . }};

      if ($http_x_forwarded_proto = '') {
        set $http_x_forwarded_proto  $scheme;
      }
      ## Application specific logs
      ## access_log /var/log/nginx/artifactory-access.log timing;
      ## error_log /var/log/nginx/artifactory-error.log;
      rewrite ^/$ /artifactory/webapp/ redirect;
      rewrite ^/artifactory/?(/webapp)?$ /artifactory/webapp/ redirect;
      if ( $repo != "" ) {
        rewrite ^/(v1|v2)/(.*) /artifactory/api/docker/$repo/$1/$2 break;
      }
      rewrite ^/(v1|v2)/([^/]+)(.*)$ /artifactory/api/docker/$2/$1/$3;
      rewrite ^/(v1|v2)/ /artifactory/api/docker/$1/;
      chunked_transfer_encoding on;
      client_max_body_size 0;
      location /artifactory/ {
        proxy_read_timeout  900;
        proxy_pass_header   Server;
        proxy_cookie_path   ~*^/.* /;
        if ( $request_uri ~ ^/artifactory/(.*)$ ) {
          proxy_pass       http://{{ include "artifactory.fullname" . }}:{{ .Values.artifactory.externalPort }}/artifactory/$1;
        }
        proxy_pass          http://{{ include "artifactory.fullname" . }}:{{ .Values.artifactory.externalPort }}/artifactory/;
        proxy_set_header    X-Artifactory-Override-Base-Url $http_x_forwarded_proto://$host:$server_port/artifactory;
        proxy_set_header    X-Forwarded-Port  $server_port;
        proxy_set_header    X-Forwarded-Proto $http_x_forwarded_proto;
        proxy_set_header    Host              $http_host;
        proxy_set_header    X-Forwarded-For   $proxy_add_x_forwarded_for;
      }
    }
```

2. Install/upgrade artifactory:
```bash
helm upgrade --install artifactory jfrog/artifactory -f nginx-values.yaml
```


#### Steps to use static configuration for reverse proxy in nginx.
1.  Get Artifactory service name using this command `kubectl get svc -n $NAMESPACE`

2.  Create `artifactory.conf` file with nginx configuration. More [nginx configuration examples](https://github.com/jfrog/artifactory-docker-examples/tree/master/files/nginx/conf.d) 
    
    Following is example `artifactory.conf`
    
    **Note**: 
    *   Create file with name `artifactory.conf` as it's fixed in configMap key. 
    *   Replace `artifactory-artifactory` with service name taken from step 1.
    
    ```bash
    ## add ssl entries when https has been set in config
    ssl_certificate      /var/opt/jfrog/nginx/ssl/tls.crt;
    ssl_certificate_key  /var/opt/jfrog/nginx/ssl/tls.key;
    ssl_session_cache shared:SSL:1m;
    ssl_prefer_server_ciphers   on;
    ## server configuration
    server {
      listen 443 ssl;
      listen 80;
      ## Change to you DNS name you use to access Artifactory 
      server_name ~(?<repo>.+)\.artifactory-artifactory artifactory-artifactory;

      if ($http_x_forwarded_proto = '') {
        set $http_x_forwarded_proto  $scheme;
      }
      ## Application specific logs
      ## access_log /var/log/nginx/artifactory-access.log timing;
      ## error_log /var/log/nginx/artifactory-error.log;
      rewrite ^/$ /artifactory/webapp/ redirect;
      rewrite ^/artifactory/?(/webapp)?$ /artifactory/webapp/ redirect;
      if ( $repo != "" ) {
        rewrite ^/(v1|v2)/(.*) /artifactory/api/docker/$repo/$1/$2 break;
      }
      rewrite ^/(v1|v2)/([^/]+)(.*)$ /artifactory/api/docker/$2/$1/$3;
      rewrite ^/(v1|v2)/ /artifactory/api/docker/$1/;
      chunked_transfer_encoding on;
      client_max_body_size 0;
      location /artifactory/ {
        proxy_read_timeout  900;
        proxy_pass_header   Server;
        proxy_cookie_path   ~*^/.* /;
        if ( $request_uri ~ ^/artifactory/(.*)$ ) {
            proxy_pass          http://artifactory-artifactory:8081/artifactory/$1 break;
        }
        proxy_pass          http://artifactory-artifactory:8081/artifactory/;
        proxy_set_header    X-Artifactory-Override-Base-Url $http_x_forwarded_proto://$host:$server_port/artifactory;
        proxy_set_header    X-Forwarded-Port  $server_port;
        proxy_set_header    X-Forwarded-Proto $http_x_forwarded_proto;
        proxy_set_header    Host              $http_host;
        proxy_set_header    X-Forwarded-For   $proxy_add_x_forwarded_for;
      }
    }
    ```
    
3.  Create configMap of `artifactory.conf` created with step above.
    ```bash
    kubectl create configmap art-nginx-conf --from-file=artifactory.conf
    ```
4.  Deploy Artifactory using helm chart.
    You can achieve this by providing the name of configMap created above to `nginx.customArtifactoryConfigMap` in [values.yaml](values.yaml) 
    
    Following is command to set values at runtime:
    ```bash
    helm install --name artifactory nginx.customArtifactoryConfigMap=art-nginx-conf jfrog/artifactory
    ```