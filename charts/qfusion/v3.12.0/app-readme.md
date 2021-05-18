# QFusion

[QFusion](http://www.woqutech.com/products.php?id=141) 是一款基于Docker容器和k8s编排技术，提供MySQL、Oracle、MSSQL、PostgreSQL等关系型数据库服务的私有云平台，并且通过kubernetes官方社区的软件一致性认证。

## Introduction

This chart bootstraps QFusion Install Operator deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Chart Details

This chart can install multiple QFusion components as subcharts:
- MySql RDS
- Mssql RDS
- Redis RDS
- EFK
- grafana
- prometheus

To enable or disable each component, change the corresponding `enabled` flag.
