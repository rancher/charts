This chart is based on the upstream [k8snetworkplumbingwg/sriov-network-operator](https://github.com/k8snetworkplumbingwg/sriov-network-operator) project. The chart deploys the SR-IOV Operator and its CRDs. It allows users to deploy SR-IOV CNI, which can be used, together with Multus, to provide high performing extra network interfaces to pods.


The chart installs the following components:

    SR-IOV Operator - The operator helps provision and configure SR-IOV CNI plugin and Device plugin. It requires Multus to operate correctly.
    SR-IOV Network Config Daemon - Deployed by the operator, this daemon is responsible for discovering the SR-IOV NICs on each node

Note that SR-IOV requires NICs that support SR-IOV and the activation of specific configuration options in the operating system. Nodes that fultill these requirements should be labeled with:

`feature.node.kubernetes.io/network-sriov.capable=true`

The SR-IOV Network Config Daemon will be deployed on such capable nodes. For more information on how to use this feature, refer to our RKE2 networking docs.
