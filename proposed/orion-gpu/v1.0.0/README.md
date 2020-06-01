# VirtAI Orion Virtual GPU Platform

VirtAI Orion Platform can virtualize GPUs and create GPU resource pool to:

* Aggregate physical GPUs resides on different servers, making GPU resources easy to manage and use!
* Create multiple virtual GPUs from a single physical GPU
  * Resource isolation and throttling
  * Improve GPU utilization
  * Save money!
* Turn every CPU server into GPU server
  * Access remote GPU on a CPU only server. No sweat!
* Dynamic scaling
  * Request more virtual GPU resources on the fly!
  * Change Orion virtual GPU settings without reboot!

## Prerequsitions

Please visit [VirtAI Tech](https://www.virtaitech.com/) for more information.

* Kubernetes version >= 1.6 to use `multischeduler` feature, otherwise `orion-scheduler` will not work.
* Properly installed NVidia GPU drivers on GPU nodes. Orion will **NOT** try to handle these drivers.
* Container runtime `containerd` with version >= 1.3.2
  * NVidia docker runtime enabled (and is set to default) on GPU nodes.
  * Check the container runtime by `kubectl get node [nodename]`
* Orion assumes the network interface to be used has exactly the same name among all nodes (e.g. `eth0`). If not, it's users' responsibility to properly config these network interface names.
* (recommaned) Properly configured RDMA environment for best performance.
  * If Infiniband is used, OFED should be properly installed.

## Chart Details

This chart will do the following:

* Deploy Orion controller (with web portal)
* Deploy Orion server
* Deploy Orion kubernetes device plugin
* Deploy Orion scheduler
* Deploy Orion monitor
* Deploy Orion helper (for labeling kubernetes nodes)

## Post Installation

`orion-helper` will try to label Kubernetes nodes automatically, however, the user is suggested to check Kubernetes node labels:

```bash
kubectl describe node [nodeName]
```

You should see something similar as the following line among the output:
> Labels:             ORION_BIND_ADDR=10.10.50.100

If not, it's users' responsibility to add this label, where the address should be the ip address of the network interface user defined during the deployment phase (e.g. `eth0`).

```bash
kubectl label nodes [nodeName] ORION_BIND_ADDR=10.10.50.100
```

## Use Orion VGPU

Here is an example yaml file to deploy Orion client and use Orion vgpu.
Please visit [VirtAI Tech](https://www.virtaitech.com/) to get detailed docs on how to deploy Orion client and run GPU workload.

```yaml
# orion-client.yaml
apiVersion: v1
kind: Pod
metadata:
  name: testgpu
spec:
  schedulerName: orion-scheduler
  hostIPC: true
  containers:
  - name: test
    image: virtaitech/orion-client-2.2:cuda10.1-tf1.14-py3.6-hvd
    command: ["sleep infinity"]
    # Please make sure these values are properly set
    env:
    - name: ORION_VGPU
      value: "1"
    - name: ORION_GMEM
      value: "4096"
    - name: ORION_RATIO
      value: "100"
    - name : ORION_GROUP_ID
      valueFrom:
        fieldRef:
          fieldPath: metadata.uid
    resources:
      limits:
        # if you have changed Resource Name while deploying Orion services, please change this accordingly
        virtaitech.com/gpu: 1
```

## Troubleshooting

* Orion Device Plugin
  * > 2020/05/21 06:58:33 Fail to get device list. Retry in 2 seconds ...
    * Please make sure `License Key` is provided. Orion requires a license key to use. If you do not have one, please visit <https://www.virtaitech.com/product/index> to get one.
  * > 2020/05/21 06:58:03 Waiting for network interface eth0
    * Orion assumes the network interface to be used has exactly the same name among all nodes (e.g. `eth0`). If not, it's users' responsibility to properly config these network interface names.
  * > Cannot reach orion contoller...
    * Invalid license key could make orion controller exit immediately. Please check orion controller logs at `/root/controller.log`.
* Orion Server
  * > 2020-05-21 07:02:33 [INFO] Waiting for net eth0 becoming ready ...
    * Orion assumes the network interface to be used has exactly the same name among all nodes (e.g. `eth0`). If not, it's users' responsibility to properly config these network interface names.
* Orion Monitor
  * > time="2020-05-21T06:58:03Z" level=info msg="Starting dcgm-exporter"  
    > Error: Failed to initialize NVML  
    > time="2020-05-21T06:58:03Z" level=fatal msg="Error starting nv-hostengine: DCGM initialization error"
    * You can safely ignore this message if the monitor is deployed on CPU only node. If you get these messages on GPU nodes, please make sure you have NVidia drivers and container runtime properly installed.

## Known issues

* Orion controller web portal cannot show GPU utilizations.

## Useful links

* [VirtAI Tech](https://www.virtaitech.com)
* [User Guide](https://github.com/virtaitech/orion-docs/blob/master/Orion-User-Guide.md)

## Activate Your Orion

Don't have a license? Please visit [VirtAI Tech](https://www.virtaitech.com) to get one. FREE trail is also available!
