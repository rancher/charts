{{/* vim: set filetype=mustache: */}}
{{/*
Create a short app name.
*/}}
{{- define "splice.name" -}}
splice
{{- end -}}

{{/*
Create the domain name part of services.
The HDFS config file should specify FQDN of services. Otherwise, Kerberos
login may fail.
*/}}
{{- define "svc-domain" -}}
{{- printf "%s.svc.cluster.local" .Release.Namespace -}}
{{- end -}}


{{/*
Create a fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "splice.fullname" -}}
{{- if .Values.global.fullnameOverride -}}
{{- .Values.global.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the subchart label.
*/}}
{{- define "splice.subchart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
Build the DNS Prefix with a - at the end, or empty.
*/}}
{{- define "dnsPrefix" -}}
{{- if .Values.global.dnsPrefix -}}
{{- printf "%s-" .Values.global.dnsPrefix -}}
{{- else -}}
{{- printf "" -}}
{{- end -}}
{{- end -}}

{{/*
Get the framework Id
*/}}
{{- define "frameworkId" -}}
{{ .Values.global.frameworkId }}
{{- end -}}



{{- define "zookeeper-fullname" -}}
{{- $fullname := include "splice.fullname" . -}}
{{- if contains "zookeeper" $fullname -}}
{{- printf "%s" $fullname -}}
{{- else -}}
{{- printf "%s-zookeeper" $fullname | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "zookeeper.name" -}}
{{- template "splice.name" . -}}-zookeeper
{{- end -}}

{{/*
Return the proper zookeeper image name
*/}}
{{- define "zookeeper.image" -}}
{{- $registryName := .Values.image.registry -}}
{{- $repositoryName := .Values.image.repository -}}
{{- $tag := .Values.image.tag | toString -}}
{{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- end -}}

{{/*
Create the zookeeper quorum server list.  The below uses two loops to make
sure the last item does not have comma. It uses index 0 for the last item
since that is the only special index that helm template gives us.
*/}}
{{- define "zookeeper-quorum" -}}
{{- if .Values.global.zookeeperQuorumOverride -}}
{{- .Values.global.zookeeperQuorumOverride -}}
{{- else -}}
{{- $service := include "zookeeper-fullname" . -}}
{{- $domain := include "svc-domain" . -}}
{{- $replicas := .Values.global.zookeeper.quorumSize | int -}}
{{- range $i, $e := until $replicas -}}
  {{- if ne $i 0 -}}
    {{- printf "%s-%d.%s-headless.%s:2181," $service $i $service $domain -}}
  {{- end -}}
{{- end -}}
{{- range $i, $e := until $replicas -}}
  {{- if eq $i 0 -}}
    {{- printf "%s-%d.%s-headless.%s:2181" $service $i $service $domain -}}
  {{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}



{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "hadoop.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "hadoop.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "hadoop.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "hadoop.config.name" -}}
{{- template "splice.fullname" . -}}-hadoop-config
{{- end -}}

{{/*
Return the proper hdfs image name
*/}}
{{- define "hdfs-image" -}}
{{- $registryName := .Values.global.hdfs.image.registry -}}
{{- $repositoryName := .Values.global.hdfs.image.repository -}}
{{- printf "%s/%s" $registryName $repositoryName -}}
{{- end -}}


{{- define "hdfs.journalnode.name" -}}
{{- template "splice.name" . -}}-hdfs-jn
{{- end -}}

{{- define "hdfs.journalnode.fullname" -}}
{{- $fullname := include "splice.fullname" . -}}
{{- if contains "hdfs-jn" $fullname -}}
{{- printf "%s" $fullname -}}
{{- else -}}
{{- printf "%s-hdfs-jn" $fullname | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "hdfs.journalnode.component" -}}
hdfs-jn
{{- end -}}

{{- define "hdfs.journalnode.datadir" -}}
{{ .Values.journalNode.datadir }}
{{- end -}}


{{/*
Create the journalnode quorum server list.  The below uses two loops to make
sure the last item does not have the delimiter. It uses index 0 for the last
item since that is the only special index that helm template gives us.
*/}}
{{- define "journalnode-quorum" -}}
{{- $service := include "hdfs.journalnode.fullname" . -}}
{{- $domain := include "svc-domain" . -}}
{{- $replicas := .Values.global.journalnodeQuorumSize | int -}}
{{- range $i, $e := until $replicas -}}
  {{- if ne $i 0 -}}
    {{- printf "%s-%d.%s.%s:8485;" $service $i $service $domain -}}
  {{- end -}}
{{- end -}}
{{- range $i, $e := until $replicas -}}
  {{- if eq $i 0 -}}
    {{- printf "%s-%d.%s.%s:8485" $service $i $service $domain -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{- define "hdfs.namenode.fullname" -}}
{{- $fullname := include "splice.fullname" . -}}
{{- if contains "hdfs-nn" $fullname -}}
{{- printf "%s" $fullname -}}
{{- else -}}
{{- printf "%s-hdfs-nn" $fullname | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "hdfs.namenode.component" -}}
hdfs-nn
{{- end -}}


{{- define "hdfs.namenode.datadir" -}}
{{ .Values.nameNode.datadir }}
{{- end -}}

{{- define "hdfs.namenode.url" -}}
http://{{- template "hdfs.namenode.fullname" . -}}:{{ .Values.nameNode.ports.webhdfs }}
{{- end -}}



{{/*
Construct the name of the namenode pod 0.
*/}}
{{- define "namenode-pod-0" -}}
{{- template "hdfs.namenode.fullname" . -}}-0
{{- end -}}

{{/*
Construct the full name of the namenode statefulset member 0.
*/}}
{{- define "namenode-svc-0" -}}
{{- $pod := include "namenode-pod-0" . -}}
{{- $service := include "hdfs.namenode.fullname" . -}}
{{- $domain := include "svc-domain" . -}}
{{- printf "%s.%s.%s" $pod $service $domain -}}
{{- end -}}

{{/*
Construct the name of the namenode pod 1.
*/}}
{{- define "namenode-pod-1" -}}
{{- template "hdfs.namenode.fullname" . -}}-1
{{- end -}}

{{/*
Construct the full name of the namenode statefulset member 1.
*/}}
{{- define "namenode-svc-1" -}}
{{- $pod := include "namenode-pod-1" . -}}
{{- $service := include "hdfs.namenode.fullname" . -}}
{{- $domain := include "svc-domain" . -}}
{{- printf "%s.%s.%s" $pod $service $domain -}}
{{- end -}}


{{- define "hdfs.datanode.fullname" -}}
{{- $fullname := include "splice.fullname" . -}}
{{- if contains "hdfs-dn" $fullname -}}
{{- printf "%s" $fullname -}}
{{- else -}}
{{- printf "%s-hdfs-dn" $fullname | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "hdfs.datanode.component" -}}
hdfs-dn
{{- end -}}


{{- define "hdfs.datanode.datadir" -}}
{{ .Values.dataNode.datadir}}
{{- end -}}

{{- define "hdfs.datanode.fulldatadir" -}}
{{- $dirName := include "hdfs.datanode.datadir" . -}}
{{- $replicas := .Values.dataNode.persistence.count | int -}}
{{- range $i, $e := until $replicas -}}
  {{- if ne $i 0 -}}
    {{- printf "file://%s-%d," $dirName $i -}}
  {{- end -}}
{{- end -}}
{{- range $i, $e := until $replicas -}}
  {{- if eq $i 0 -}}
    {{- printf "file://%s-%d" $dirName $i -}}
  {{- end -}}
{{- end -}}
{{- end -}}


{{/*
Return the proper hbase image name
*/}}
{{- define "hbase.image" -}}
{{- $registryName := .Values.image.registry -}}
{{- $repositoryName := .Values.image.repository -}}
{{- printf "%s/%s" $registryName $repositoryName -}}
{{- end -}}

{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "hbase.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "hbase.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "hbase.config.name" -}}
{{- template "splice.fullname" . -}}-hbase-config
{{- end -}}

{{- define "spark.config.name" -}}
{{- template "splice.fullname" . -}}-spark-config
{{- end -}}

{{- define "hbase.hmaster.name" -}}
{{- template "splice.name" . -}}-hmaster
{{- end -}}

{{- define "hbase.hmaster.fullname" -}}
{{- $fullname := include "splice.fullname" . -}}
{{- if contains "hmaster" $fullname -}}
{{- printf "%s" $fullname -}}
{{- else -}}
{{- printf "%s-hmaster" $fullname | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "hbase.hmaster.component" -}}
hmaster
{{- end -}}

{{/*
Construct the full name of the hmaster statefulset member 0.
*/}}
{{- define "hbase-hmaster-svc-0" -}}
{{- $service := include "hbase.hmaster.fullname" . -}}
{{- $domain := include "svc-domain" . -}}
{{- printf "%s-0.%s.%s" $service $service $domain -}}
{{- end -}}

{{- define "hbase.hregion.name" -}}
{{- template "splice.name" . -}}-hregion
{{- end -}}

{{- define "hbase.hregion.fullname" -}}
{{- $fullname := include "splice.fullname" . -}}
{{- if contains "hregion" $fullname -}}
{{- printf "%s" $fullname -}}
{{- else -}}
{{- printf "%s-hregion" $fullname | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "hbase.hregion.component" -}}
hregion
{{- end -}}

{{/*
Construct the full name of the hregion statefulset member 0.
*/}}
{{- define "hbase-hregion-svc-0" -}}
{{- $service := include "hbase.hregion.fullname" . -}}
{{- $domain := include "svc-domain" . -}}
{{- printf "%s-0.%s.%s" $service $service $domain -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "hbase.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "hbase.executor.name" -}}
{{- template "splice.name" . -}}-sparkexec
{{- end -}}


{{- define "hbase.olap.name" -}}
{{- template "splice.name" . -}}-olap
{{- end -}}

{{- define "hbase.olap.fullname" -}}
{{- $fullname := include "splice.fullname" . -}}
{{- if contains "olap" $fullname -}}
{{- printf "%s" $fullname -}}
{{- else -}}
{{- printf "%s-olap" $fullname | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "olap.config.name" -}}
{{- template "splice.fullname" . -}}-olap-config
{{- end -}}

{{- define "hbase.olap.component" -}}
olap
{{- end -}}

{{/*
Construct the full name of the olap statefulset member 0.
*/}}
{{- define "hbase-olap-svc-0" -}}
{{- $service := include "hbase.olap.fullname" . -}}
{{- $domain := include "svc-domain" . -}}
{{- printf "%s-0.%s.%s" $service $service $domain -}}
{{- end -}}

{{/* vim: set filetype=mustache: */}}
{{/*
Create a short app name.
*/}}

{{- define "jvmprofiler.fullname" -}}
{{- $fullname := include "splice.fullname" . -}}
{{- if contains "jvmprofiler" $fullname -}}
{{- printf "%s" $fullname -}}
{{- else -}}
{{- printf "%s-jvmprofiler" $fullname | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "jvmprofiler.name" -}}
{{- template "splice.name" . -}}-jvmprofiler
{{- end -}}

{{/*
Return the proper jvmprofiler image name
*/}}
{{- define "jvmprofiler.image" -}}
{{- $registryName := .Values.image.registry -}}
{{- $repositoryName := .Values.image.repository -}}
{{- $tag := .Values.image.tag | toString -}}
{{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- end -}}

{{/*
Create a short app name.
*/}}

{{- define "plsql.fullname" -}}
{{- $fullname := include "splice.fullname" . -}}
{{- if contains "plsql" $fullname -}}
{{- printf "%s" $fullname -}}
{{- else -}}
{{- printf "%s-plsql" $fullname | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "plsql.name" -}}
{{- template "splice.name" . -}}-plsql
{{- end -}}

{{/*
Return the proper plsql image name
*/}}
{{- define "plsql.image" -}}
{{- $registryName := .Values.image.registry -}}
{{- $repositoryName := .Values.image.repository -}}
{{- $tag := .Values.image.tag | toString -}}
{{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- end -}}

{{- define "hbase.postinstall.fullname" -}}
{{- $fullname := include "splice.fullname" . -}}
{{- if contains "postinstall" $fullname -}}
{{- printf "%s" $fullname -}}
{{- else -}}
{{- printf "%s-postinstall" $fullname | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "hbase.postinstall.component" -}}
postinstall
{{- end -}}

{{- define "hbase.postrestart.fullname" -}}
{{- $fullname := include "splice.fullname" . -}}
{{- if contains "postrestart" $fullname -}}
{{- printf "%s" $fullname -}}
{{- else -}}
{{- printf "%s-postrestart" $fullname | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "hbase.postrestart.component" -}}
postrestart
{{- end -}}


{{- define "hbase.dbbackup.fullname" -}}
{{- $fullname := include "splice.fullname" . -}}
{{- if contains "dbbackup" $fullname -}}
{{- printf "%s" $fullname -}}
{{- else -}}
{{- printf "%s-dbbackup" $fullname | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "hbase.dbbackup.component" -}}
backup
{{- end -}}


{{/*
Create a short app name.
*/}}

{{- define "mlflow.fullname" -}}
{{- $fullname := include "splice.fullname" . -}}
{{- if contains "mlflow" $fullname -}}
{{- printf "%s" $fullname -}}
{{- else -}}
{{- printf "%s-mlflow" $fullname | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "mlflow.name" -}}
{{- template "splice.name" . -}}-mlflow
{{- end -}}

{{/*
Return the proper mlflow image name
*/}}
{{- define "mlflow.image" -}}
{{- $registryName := .Values.mlflow.image.registry -}}
{{- $repositoryName := .Values.mlflow.image.repository -}}
{{- printf "%s/%s" $registryName $repositoryName -}}
{{- end -}}

{{/*
Create a short app name.
*/}}

{{- define "bobby.fullname" -}}
{{- $fullname := include "splice.fullname" . -}}
{{- if contains "bobby" $fullname -}}
{{- printf "%s" $fullname -}}
{{- else -}}
{{- printf "%s-bobby" $fullname | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "bobby.name" -}}
{{- template "splice.name" . -}}-bobby
{{- end -}}

{{/*
Return the proper bobby image name
*/}}
{{- define "bobby.image" -}}
{{- $registryName := .Values.bobby.image.registry -}}
{{- $repositoryName := .Values.bobby.image.repository -}}
{{- printf "%s/%s" $registryName $repositoryName -}}
{{- end -}}


{{/*
Return the full jdbc url for the service including user and password
*/}}
{{- define "jdbc.fullurl" -}}
{{- $jdbcServer := include "hbase.hregion.fullname" . -}}
{{- $spliceUser := .Values.global.splice.user -}}
{{- $splicePassword := .Values.global.splice.password -}}
{{- printf "jdbc:splice://%s-headless:1527/splicedb;user=%s;password=%s" $jdbcServer $spliceUser $splicePassword -}}
{{- end -}}

{{/*
Return the jdbc url for the service
*/}}
{{- define "jdbc.url" -}}
{{- $jdbcServer := include "hbase.hregion.fullname" . -}}
{{- printf "jdbc:splice://%s-headless:1527/splicedb" $jdbcServer -}}
{{- end -}}

{{/*
Return the proper base image name
*/}}
{{- define "base-image" -}}
{{- $registryName := .Values.global.baseImage.registry -}}
{{- $repositoryName := .Values.global.baseImage.repository -}}
{{- $tag := .Values.global.baseImage.tag | toString -}}
{{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- end -}}

{{/*
Return the proper spark image name
*/}}
{{- define "spark-image" -}}
{{- $registryName := .Values.global.spark.image.registry -}}
{{- $repositoryName := .Values.global.spark.image.repository -}}
{{- printf "%s/%s" $registryName $repositoryName -}}
{{- end -}}



{{- define "kafka.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "kafka.image" -}}
{{- $registryName := .Values.image.registry -}}
{{- $repositoryName := .Values.image.repository -}}
{{- $tag := .Values.image.tag | toString -}}
{{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- end -}}

{{- define "kafka.name" -}}
{{- template "splice.name" . -}}-kafka
{{- end -}}

{{- define "kafka.fullname" -}}
{{- $fullname := include "splice.fullname" . -}}
{{- if contains "kafka" $fullname -}}
{{- printf "%s" $fullname -}}
{{- else -}}
{{- printf "%s-kafka" $fullname | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "kafka.component" -}}
kafka-broker
{{- end -}}

{{- define "kafka.config.name" -}}
{{- template "splice.fullname" . -}}-kafka-config
{{- end -}}

{{- define "spark.mem.total" -}}
{{- $mem := .Values.config.sparkexecutormemory | trimSuffix "m" | int -}}
{{- $overheard := .Values.config.sparkexecutormemoryoverhead | trimSuffix "m" | int -}}
{{- $total := add $mem $overheard -}}
{{- printf "%dm" $total -}}
{{- end -}}

{{- define "hadoop.nameNode.ingress.hosts.0" -}}
{{- $certName := .Values.global.certificateName | toString -}}
{{- $dnsPrefix := .Values.global.dnsPrefix | toString -}}
{{- if .Values.global.addEnvironmentToDNSNames -}}
  {{- $envName := printf "-%s" .Values.global.environmentName -}}
  {{- printf "%s%sadmin-hdfs.%s" $dnsPrefix $envName $certName -}}
{{- else -}}
  {{- $envName := "" -}}
  {{- printf "%s%sadmin-hdfs.%s" $dnsPrefix $envName $certName -}}
{{- end -}}
{{- end -}}

{{- define "hadoop.nameNode.ingress.tls.0" -}}
{{- $certName := .Values.global.certificateName | toString -}}
{{- $dnsPrefix := .Values.global.dnsPrefix | toString -}}
{{- $hostName := include "hadoop.nameNode.ingress.hosts.0" . -}}
- hosts:
  - {{ $hostName }}
  secretName: {{ $certName }}
{{- end -}}

{{- define "hbase.master.ingress.hosts.0" -}}
{{- $certName := .Values.global.certificateName | toString -}}
{{- $dnsPrefix := .Values.global.dnsPrefix | toString -}}
{{- $addEnv := .Values.global.addEnvironmentToDNSNames | toString -}}
{{- if eq $addEnv "true" -}}
  {{- $envName := printf "-%s" .Values.global.environmentName -}}
  {{- printf "%s%sadmin-hbase.%s" $dnsPrefix $envName $certName -}}
{{- else -}}
  {{- $envName := "" -}}
  {{- printf "%s%sadmin-hbase.%s" $dnsPrefix $envName $certName -}}
{{- end -}}
{{- end -}}

{{- define "hbase.master.ingress.tls.0" -}}
{{- $certName := .Values.global.certificateName | toString -}}
{{- $dnsPrefix := .Values.global.dnsPrefix | toString -}}
{{- $hostName := include "hbase.master.ingress.hosts.0" . -}}
- hosts:
  - {{ $hostName }}
  secretName: {{ $certName }}
{{- end -}}

{{- define "hbase.olap.sparkIngress.hosts.0" -}}
{{- $certName := .Values.global.certificateName | toString -}}
{{- $dnsPrefix := .Values.global.dnsPrefix | toString -}}
{{- if .Values.global.addEnvironmentToDNSNames -}}
  {{- $envName := printf "-%s" .Values.global.environmentName -}}
  {{- printf "%s%s%s.%s" $dnsPrefix $envName "spark" $certName -}}
{{- else -}}
  {{- $envName := "" -}}
  {{- printf "%s%s%s.%s" $dnsPrefix $envName "spark" $certName -}}
{{- end -}}
{{- end -}}

{{- define "hbase.olap.sparkIngress.tls.0" -}}
{{- $certName := .Values.global.certificateName | toString -}}
{{- $dnsPrefix := .Values.global.dnsPrefix | toString -}}
{{- $hostName := include "hbase.olap.sparkIngress.hosts.0" . -}}
- hosts:
  - {{ $hostName }}
  secretName: {{ $certName }}
{{- end -}}

{{- define "hbase.region.ingress.hosts.0" -}}
{{- $certName := .Values.global.certificateName | toString -}}
{{- $dnsPrefix := .Values.global.dnsPrefix | toString -}}
{{- if .Values.global.addEnvironmentToDNSNames -}}
  {{- $envName := printf "-%s" .Values.global.environmentName -}}
  {{- printf "%s%s.%s" $dnsPrefix $envName $certName -}}
{{- else -}}
  {{- $envName := "" -}}
  {{- printf "%s%s.%s" $dnsPrefix $envName $certName -}}
{{- end -}}
{{- end -}}

{{- define "hbase.region.ingress.tls.0" -}}
{{- $certName := .Values.global.certificateName | toString -}}
{{- $dnsPrefix := .Values.global.dnsPrefix | toString -}}
{{- $hostName := include "hbase.region.ingress.hosts.0" . -}}
- hosts:
  - {{ $hostName }}
  secretName: {{ $certName }}
{{- end -}}

{{- define "jvmprofiler.ingress.hosts.0" -}}
{{- $certName := .Values.global.certificateName | toString -}}
{{- $dnsPrefix := .Values.global.dnsPrefix | toString -}}
{{- if .Values.global.addEnvironmentToDNSNames -}}
  {{- $envName := printf "-%s" .Values.global.environmentName -}}
  {{- printf "%s%sadmin.%s" $dnsPrefix $envName $certName -}}
{{- else -}}
  {{- $envName := "" -}}
  {{- printf "%s%sadmin.%s" $dnsPrefix $envName $certName -}}
{{- end -}}
{{- end -}}

{{- define "jvmprofiler.ingress.tls.0" -}}
{{- $certName := .Values.global.certificateName | toString -}}
{{- $dnsPrefix := .Values.global.dnsPrefix | toString -}}
{{- $hostName := include "jvmprofiler.ingress.hosts.0" . -}}
- hosts:
  - {{ $hostName }}
  secretName: {{ $certName }}
{{- end -}}

{{- define "mlmanager.mlflow.ingress.hosts.0" -}}
{{- $certName := .Values.global.certificateName | toString -}}
{{- $dnsPrefix := .Values.global.dnsPrefix | toString -}}
{{- if .Values.global.addEnvironmentToDNSNames -}}
  {{- $envName := printf "-%s" .Values.global.environmentName -}}
  {{- printf "%s%s.%s" $dnsPrefix $envName $certName -}}
{{- else -}}
  {{- $envName := "" -}}
  {{- printf "%s%s.%s" $dnsPrefix $envName $certName -}}
{{- end -}}
{{- end -}}

{{- define "mlmanager.mlflow.ingress.tls.0" -}}
{{- $certName := .Values.global.certificateName | toString -}}
{{- $dnsPrefix := .Values.global.dnsPrefix | toString -}}
{{- $hostName := include "mlmanager.mlflow.ingress.hosts.0" . -}}
- hosts:
  - {{ $hostName }}
  secretName: {{ $certName }}
{{- end -}}

{{- define "mlmanager.mlflow.jobtracker.ingress.hosts.0" -}}
{{- $certName := .Values.global.certificateName | toString -}}
{{- $dnsPrefix := .Values.global.dnsPrefix | toString -}}
{{- if .Values.global.addEnvironmentToDNSNames -}}
  {{- $envName := printf "-%s" .Values.global.environmentName -}}
  {{- printf "%s%s-jobtracker.%s" $dnsPrefix $envName $certName -}}
{{- else -}}
  {{- $envName := "" -}}
  {{- printf "%s%s-jobtracker.%s" $dnsPrefix $envName $certName -}}
{{- end -}}
{{- end -}}

{{- define "mlmanager.mlflow.jobtracker.ingress.tls.0" -}}
{{- $certName := .Values.global.certificateName | toString -}}
{{- $dnsPrefix := .Values.global.dnsPrefix | toString -}}
{{- $hostName := include "mlmanager.mlflow.jobtracker.ingress.hosts.0" . -}}
- hosts:
  - {{ $hostName }}
  secretName: {{ $certName }}
{{- end -}}

{{- define "kafka.ingress.hosts.0" -}}
{{- $certName := .Values.global.certificateName | toString -}}
{{- $dnsPrefix := .Values.global.dnsPrefix | toString -}}
{{- if .Values.global.addEnvironmentToDNSNames -}}
  {{- $envName := printf "-%s" .Values.global.environmentName -}}
  {{- printf "%s%s-kafka.%s" $dnsPrefix $envName $certName -}}
{{- else -}}
  {{- $envName := "" -}}
  {{- printf "%s%s-kafka.%s" $dnsPrefix $envName $certName -}}
{{- end -}}
{{- end -}}

{{- define "kafka.ingress.tls.0" -}}
{{- $certName := .Values.global.certificateName | toString -}}
{{- $dnsPrefix := .Values.global.dnsPrefix | toString -}}
{{- $hostName := include "kafka.ingress.hosts.0" . -}}
- hosts:
  - {{ $hostName }}
  secretName: {{ $certName }}
{{- end -}}

{{- define "kafka.external.domain" -}}
{{- $certName := .Values.global.certificateName | toString -}}
{{- $dnsPrefix := .Values.global.dnsPrefix | toString -}}
{{- if .Values.global.addEnvironmentToDNSNames -}}
  {{- $envName := printf "-%s" .Values.global.environmentName -}}
  {{- printf "%s%s.%s" $dnsPrefix $envName $certName -}}
{{- else -}}
  {{- $envName := "" -}}
  {{- printf "%s%s.%s" $dnsPrefix $envName $certName -}}
{{- end -}}
{{- end -}}

{{- define "jupyterhub.ingress.hosts.0" -}}
{{- $certName := .Values.global.certificateName | toString -}}
{{- $dnsPrefix := .Values.global.dnsPrefix | toString -}}
{{- if .Values.global.addEnvironmentToDNSNames -}}
  {{- $envName := printf "-%s" .Values.global.environmentName -}}
  {{- printf "%s%s.%s" $dnsPrefix $envName $certName -}}
{{- else -}}
  {{- $envName := "" -}}
  {{- printf "%s%s.%s" $dnsPrefix $envName $certName -}}
{{- end -}}
{{- end -}}

{{- define "jupyterhub.ingress.tls.0" -}}
{{- $certName := .Values.global.certificateName | toString -}}
{{- $dnsPrefix := .Values.global.dnsPrefix | toString -}}
{{- $hostName := include "hbase.region.ingress.hosts.0" . -}}
- hosts:
  - {{ $hostName }}
  secretName: {{ $certName }}
{{- end -}}
