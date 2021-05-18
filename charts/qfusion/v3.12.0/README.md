## Prerequisites

- Kubernetes 1.14 or newer cluster with RBAC (Role-Based Access Control) enabled is required
- Helm 3.5 or newer or alternately the ability to modify RBAC rules is also required

## Resources Required

The chart deploys pods that consume minimum resources as specified in the resources configuration parameter.


我们有对可调度机器进行控制，请给允许调度qfusion数据库的机器添加如下label
```
kubectl label node <nodeName> qfusion/node= resourceusetype/share=true storagetype/csi-localpv=true
```

如果使用rancher的local集群来安装，需要在启动rancher时，添加如下参数：
1. 31080端口暴露，用于访问QFusion。其它端口可根据需要暴露
    * 30062  k8s图表
    * 30074  监控图表
    * 30064  日志中心
    * 30065,30066  监控数据
2. 挂载时区信息

```
 docker run --privileged -d \
   --restart=unless-stopped -p 8143:443 -p 31008:31080 \
   -v /usr/share/zoneinfo/Asia/Shanghai:/usr/share/zoneinfo/Asia/Shanghai \
   rancher/rancher:v2.5.7
```


## Installing the Chart

1. Add helm repo
```
$ helm repo add qfusion https://helm.woqutech.com:8043/qfusion
```

2. Install QFusion
```
$ helm install qfusion qfusion/qfusion-installer -n qfusion
```

## Uninstalling the Chart

To uninstall/delete the `qfusion` release:
```
$ kubectl delete qfi qfusion -n qfusion
```

To uninstall/delete the `qfusion` release completely and make its name free for later use:
```
$ helm delete qfusion -n qfusion
```
