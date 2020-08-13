# TiDB Operator

- [**Stack Overflow**](https://stackoverflow.com/questions/tagged/tidb)
- [**Community Slack Channel**](https://pingcap.com/tidbslack/)
- [**Reddit**](https://www.reddit.com/r/TiDB/)
- **Mailing list**: [Google Group](https://groups.google.com/forum/#!forum/tidb-user)
- [**Blog**](https://www.pingcap.com/blog/)
- [**For support, please contact PingCAP**](http://bit.ly/contact_us_via_github)

TiDB Operator manages [TiDB](https://github.com/pingcap/tidb) clusters on [Kubernetes](https://kubernetes.io) and automates tasks related to operating a TiDB cluster. It makes TiDB a truly cloud-native database.


## Features

- __Safely scaling the TiDB cluster__

    TiDB Operator empowers TiDB with horizontal scalability on the cloud.

- __Rolling update of the TiDB cluster__

    Gracefully perform rolling updates for the TiDB cluster in order, achieving zero-downtime of the TiDB cluster.

- __Multi-tenant support__

    Users can deploy and manage multiple TiDB clusters on a single Kubernetes cluster easily.

- __Automatic failover__

    TiDB Operator automatically performs failover for your TiDB cluster when node failures occur.

- __Kubernetes package manager support__

    By embracing Kubernetes package manager [Helm](https://helm.sh), users can easily deploy TiDB clusters with only one command.

- __Automatically monitoring TiDB cluster at creating__

    Automatically deploy Prometheus, Grafana for TiDB cluster monitoring.



## Documentation

All the TiDB Operator documentation is maintained in the [docs-tidb-operator repository](https://github.com/pingcap/docs-tidb-operator). You can also see the documentation at PingCAP website:

- [English](https://pingcap.com/docs/tidb-in-kubernetes/stable/tidb-operator-overview/)
- [简体中文](https://pingcap.com/docs-cn/tidb-in-kubernetes/stable/tidb-operator-overview/)
