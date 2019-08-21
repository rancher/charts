# Kafka
Kafka is used for building real-time data pipelines and streaming apps. It is horizontally scalable, fault-tolerant, wicked fast, and runs in production in thousands of companies.

## Confluent Kafka Chart

**The Confluent Kafka charts are in developer preview and are not supported for production use.**

The [Confluent Platform Helm charts](https://github.com/confluentinc/cp-helm-charts) enable you to deploy Confluent Kafka services on Kubernetes for development, test, and proof of concept environments.

## Chart Details
This chart bootstraps a [Confluent](https://docs.confluent.io/current/) Kafka platform v5.3.0. The chart has the following components,
- confluent-kafka(v2.3.0)
- confluent-zookeeper
- confluent-Kafka-schema-registry
- confluent-Kafka-rest
- confluent-kafka-ksql
- confluent-kafka-connect
- confluent-control-center(free 30 days trail, enterprise only)
- Kafka-topics-ui (This project is licensed under the [BSL](http://www.landoop.com/bsl) license.)

**Warning:** upgrade from previous version is currently not supported, please re-crate a new kafka app.