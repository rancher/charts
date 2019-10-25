# XSKY

[XSKY](https://www.xsky.com) (Beijing) Data Technology Co., Ltd. is a high-tech enterprise focusing on software defined infrastructure, 
providing software defined distributed storage product of enterprise-grade and helping customers achieve innovation in data structure.

According to the “2017Q4 China SDS and HCI Market Tracking Report” released by IDC, 
XSKY ranked Top3 in China SDS market share, Top1 in object storage market with share of 27.6% and Top3 in block storage market with share of 15.8%. 


[XSKY Block CSI](https://xsky-storage.github.io/xsky-csi-driver/csi-block.html) plugins implement interfaces of CSI. It allows dynamically provisioning XSKY volumes and attaching them to workloads. Current implementation of XSKY CSI plugins was tested in Kubernetes environment (requires Kubernetes 1.13.0+),but the code does not rely on any Kubernetes specific calls (WIP to make it k8s agnostic) and should be able to run with any CSI enabled CO.
