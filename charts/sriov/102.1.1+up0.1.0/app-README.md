# Rancher SR-IOV Network Operator

This chart is based on the upstream [k8snetworkplumbingwg/sriov-network-operator](https://github.com/k8snetworkplumbingwg/sriov-network-operator) project. The chart deploys the SR-IOV Operator and its CRDs, which are designed to help the user provision and configure the SR-IOV CNI in a cluster that uses [Multus CNI](https://github.com/k8snetworkplumbingwg/multus-cni), to provide high performing extra network interfaces to pods. This chart is expected to be deployed on an RKE2 cluster and only meant for advanced use cases where multiple CNI plugins and high performing network interfaces on pods are required. Users who do not need these features are not advised to install this chart.

The chart installs the following components:

 - SR-IOV Operator - An operator that helps provision and configure the SR-IOV CNI plugin and SR-IOV Device plugin
 - SR-IOV Network Config Daemon - A Daemon deployed by the Operator that discovers SR-IOV NICs on each node

Note that SR-IOV requires NICs that support SR-IOV and the activation of specific configuration options in the operating system. Nodes that fulfill these requirements should be labeled with: `feature.node.kubernetes.io/network-sriov.capable=true`.

The SR-IOV Network Config Daemon will be deployed on such capable nodes. For more information on how to use this feature, refer to our RKE2 networking docs.

