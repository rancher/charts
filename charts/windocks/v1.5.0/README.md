# Windocks SQL proxy

The Windocks SQL proxy delivers Windows SQL Server containers with database clones to a cluster. 
- Creates a Windows SQL Server container on a designated external machine that already has Windocks installed (A demo Windocks server is available at the IP address in the values)
- Clones terabyte sized SQL Server databases on the external Windocks server in seconds and delivers them to the container
- Proxies SQL traffic from the client applications (users, .Net apps, Sql Server Management Studio, NodeJs apps etc) to the Windocks container
- Enables the client applications to work on the cloned databases (usually production database clones) 
- Deletes the Windocks SQL Server container when the SQL proxy pod / container is deleted

## Pre-requisites
1. Windocks installed on a machine accessible to the cluster  (A demo machine is provided for you on the IP address)
2. For TLS connections, the required TLS setup on the Windocks machine and an SSL certificate and key for the proxy

## Steps

1. Use the default values for proxy image name/tag and environment variables (Windocks host ip, Windocks server port, etc. ). 

2. Create the secret: create secret generic proxy-secrets --from-literal=WINDOCKS_REQUIRED_USERNAME='windocks-api-username' --from-literal=WINDOCKS_REQUIRED_PASSWORD='windocks-api-password' --from-literal=WINDOCKS_REQUIRED_CONTAINER_SAPASSWORD='sa-password-to-set-for-windocks-container'

3. For TLS: Create a secret in a file with tls.key and tls.crt, both of which are mounted as files into the container. Separate coniguration is required on the Windocks server (support@windocks.com)

4. Deploy the app and use SQL Server Management Studio or Azure Management Studio to connect to the <Windocks=host-IP>,3087 using SQL auth: sa and the password above

Email support@windocks.com for issues

## Instructions for your own external Windocks machine

Download a free Windocks community edition from [Windocks.com](http://www.windocks.com)


### PRE-INSTALL CHECKLIST
1. Windows 8.1, 10, Pro or Enterprise editions, or Windows Server 2012 R2 or 2016. 
2. SQL Server Standard, Enterprise, Developer or Express: 2008, R2, 2012, 2014, 2016 or 2017 
3. SQL Server already installed? WIndocks will use it. Don’t use that SQL for anything else. Or
install another instance of SQL & edit node.conf to use the fresh SQL (see below) 
4. SQL Server not already installed? Install SQL before Windocks & don’t use SQL for anything
else. Login with the same BUILTIN admin account, install SQL first, then WIndocks 
5. Report Server (SSRS) must be installed in native mode for SSRS containers.

### INSTALL
After SQL Server is installed, login with a Builtin Administrator account & run the Windocks
installer. Reboot the server after a fresh install.

### VERIFY INSTALL
1. Copy the license key to a file named key.txt and save key.txt in the Windocks folder. The
machine must have Internet access to validate the license.
2. Open a Windows command prompt and create a Sql Server container as below:
docker create mssql-20xx (Replace xx with your sql version - 08, 08r2, 12, 14, 16, 17)

### POST INSTALL
1. For the web app, open ports 3000,3001, & 5985, 5986 (PowerShell remote)
2. The installer configures SQL and SSRS instance names automatically. Verify in
Windocks\config\node.conf Restart the Windocks service following any changes.

### windocks\config\node.conf (Example below is SQL Server 2014)  
<i>#</i>Get YourSqlInstanceName from services.msc, the SQL instance name is in (parenthesis)
MSSQL_2014_INSTANCE_NAME=“YourSqlInstanceName”  
MSRS_2014_INSTANCE_NAME=“YourSqlInstanceName”

### BUILD IMAGES AND SQL CONTAINERS WITH DATABASE CLONES (see windocks\samples)  
Use a command prompt to create and start a base SQL Server container:  
>docker images -- displays the list of SQL images available

>docker create mssql-2014 — use the image name from the images command

>docker ps — Verify the container was created, note the ContainerID and port

>docker start <ContainerID> -- use 2-3 unique digits of Containerid

>docker rm <containerID> -- stops and deletes the container


#### Windocks\samples\testFastCloneFromFullBackup\dockerfile  
<i>#</i> Set the SQL image to be used here. Example is for SQL 2014:  
FROM mssql-2014  
<i>#</i> The source of data for cloning is a full backup. Diff is supported see samples  
SETUPCLONING FULL customers C:\windocks\dbbackups\customerdatafull.bak  
<i>#</i> Windocks copies the data masking script to the image & runs it to prepare the image  
COPY cleanseData.sql .  
RUN cleanseData.sql  


Build an image named full1 & create a SQL Server container that includes the cloned DB.  

>docker build -t full1 C:\Windocks\samples\testFastCloneFromFullBackup

>docker images — Verify the image full1 is built

>docker create full1 — Create a container from full1, note the containerId and port

>docker start <containerid> — Start the container with 2-3 unique digits of ContainerID

Open SQL Management Studio, use the loopback address followed by a comma and port 127.0.0.1,10001. Verify the presence of the customers database.

>docker rmi full1 — Deletes image full1 (Delete associated containers first for clone images)


### WINDOCKS WEB APPLICATION  
The web app supports build images, create, start, and stop containers with data, and delivery
of database clones to SQL instances and MS SQL containers. On the Windocks machine, browse
to 127.0.0.1 (or localhost) in Chrome or Firefox. Enter 127.0.0.1 in the IP address box & Get.
On remote machines use the Windocks machine IP address instead of 127.0.0.1.


### AUTHENTICATION  
Open inetpub\wwroot\registerreset.html in Chrome/Firefox to create users. Email
support@windocks.com for the administrator password. Not available in Community edition.


### ADVANCED CONFIGURATION  

#### windocks\config\nodeAllOptions.conf. Copy line(s) to node.conf and restart Windocks service  

<i>#</i> sa passwords are not shown, encrypted, or shown in plain text, with 0, 1, 2 respectively  
SHOW_SA_PASSWORD=“1”  
<i>#</i> Container storage, default is SystemDrive:\Windocks\containers. Ensure the path exists  
CONTAINER_BASE_DIR=“D:\containers”  
<i>#</i> Assign ports to containers beginning with this port  
STARTING_PORT=10001  

<i>#</i> Don’t copy user databases in the default SQL instance to containers (1: copy)  
COPY_DEFAULT_INSTANCE_DATABASES=0  

<i>#</i> Only SQL containers and SQL scripts allowed using “1”, or all containers and EXEs =”0”  
DB_SANDBOX=“1"  

<i>#</i> User permissions for access to cloned databases in the file share: \Windocks\data  
CLONE_USERS_PERMITTED=“domain\user1, domain\user2, Everyone”  

Logins for SSRS containers require Logon as a Service permissions, set in Local Security
Policy, User Policies, User Rights Assignment.SSRS containers run as the account (needs Logon as a Service). See Encrypted Passwords  
REPORTING_SERVICE_LOGIN=“MACHINE\account”  
REPORTING_SERVICE_PASSWORD=“EncryptedPassword”  

<i>#</i> Logins for SSRS containers require Logon as a Service permissions, set in Local Security
Policy, User Policies, User Rights Assignment.


### ENCRYPTED PASSWORDS (SECRETS)  

>c:\windocks\bin\encrypt.exe — Enter the password you want to encrypt  

Result encrypted password is in “encrypted.txt”. Copy/paste to node.conf  

>c:\windocks\bin\decrypt.exe — Enter the encrypted password, see the decrypted result  



### T-SQL SCRIPT FORMAT  
Use T-SQL scripts with a single statement per SQL command, & a semi-colon at the end of
each SQL command. Details at https://windocks.com/files/windocks-scripting-sql-PDF.pdf


### UNINSTALL WINDOCKS  
1. Stop and remove all containers >docker rm <containerid>
2. Close open dockerfiles or other processes using Windocks
3. Open services.msc, right-click and stop Windocks Services
4. Open Administrative command prompt, and delete the services >sc delete windocks
5. Using File Explorer delete the Windocks directory


### ADDITIONAL RESOURCES  
See https://windocks.com/lps/resources


### TROUBLESHOOTING  
1. docker create or docker build SQL issues ? See the error message from server
• SQL Server default instance is running? Stop it in Services & set to Manual.
• SQL Server instance name? Edit Windocks\config\node.conf, enter instance name - get
it from Services / Microsoft SQL Server (InstanceName). Restart Windocks Service
2. SSRS container issues - email support@windocks.com
3. Database cloning issues. docker build -t <cloneTypeImage> - see error message
• Path to backup in dockerfile correct?
• Logged in to Windows with an account that has permissions on the backup path?
• Check dockerfile syntax for SETUPCLONING and paths to each Db file
4. SQL Scripts issues - see https://windocks.com/files/windocks-scripting-sql-PDF.pdf
• Did you miss the . (period) in COPY script.sql . ?
• Is the script present in the same directory as dockerfile or the path specified?
5. Encrypted DB backups see https://windocks.com/files/windocks-scripting-sql-PDF.pdf
RELEASE NOTES
1. Any change to node.conf, restart Windocks service
2. Creating an SSRS container takes 2 to 3 minutes. The Services view will show the container
services earlier, but DO NOT start or stop these services till the container is created.
3. SQL Server 2016 SSRS containers use ReportServer<PortNumber> as the reporting DB
4. Docker images and web UI show SSRS images even when no SSRS default instance exists
5. The Windocks web UI allows use of CAPS in image names, but the command line does not.
The result can be image names distinguished only by the presence of CAPS. Please
standardize on lower-case image names.
6. The web UI does not allow image deletion.
7. When using Windocks to serve database clones, avoid unplanned reboots or system restarts,
which can result in database clones being put into a “recovery pending” state.

### TECHNICAL SUPPORT  
Email support@windocks.com with a copy of Windocks\log\platform.log for help.