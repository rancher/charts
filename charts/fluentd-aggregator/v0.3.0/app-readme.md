# Flunetd Aggregator

Flunetd Log aggregators are statefulsets that continuously receive events from the log forwarders(flunetd daemonsets). They buffer the events and periodically upload the data into the cloud or user's logging system.

### This chart includes the following pre-installed additional fluentd plugins, Flunetd's core plugins are enabled by [default](https://docs.fluentd.org/v1.0/articles/filter-plugin-overview):

### Output Plugins:
[Elasticsearch](https://github.com/uken/fluent-plugin-elasticsearch) / [Splunk](https://github.com/fluent/fluent-plugin-splunk) / [Kafka](https://github.com/fluent/fluent-plugin-kafka) / [Remote Syslog](https://github.com/dlackty/fluent-plugin-remote_syslog) / [Kinesis](https://github.com/awslabs/aws-fluent-plugin-kinesis) / [AWS S3](https://github.com/fluent/fluent-plugin-s3)

### Filter Plugins:
[Rewrite Tag Filter](https://github.com/fluent/fluent-plugin-rewrite-tag-filter) / [Record Modifier](https://github.com/repeatedly/fluent-plugin-record-modifier) / [Concat](https://github.com/fluent-plugins-nursery/fluent-plugin-concat) / [Fields Parser](https://github.com/tomas-zemres/fluent-plugin-fields-parser)

### Parser Plugins:
[Grok parser](https://github.com/fluent/fluent-plugin-grok-parser) / [Multi Format Parser](https://github.com/repeatedly/fluent-plugin-multi-format-parser)

### Formatter Plugins:
[Formatter Sprintf](https://github.com/toyama0919/fluent-plugin-formatter_sprintf)

## Fault Tolerant and Persistent Storage
User must enable persistent storage for Fault Tolerant, the buffered data is stored on the disk. After Fluentd recovers, it will try to send the buffered data to the destination again.

Please note that the data will be lost if the buffer file is broken due to I/O errors. The data will also be lost if the disk is full, since there is nowhere to store the data on disk.

### Limitation
`Caution:` file buffer implementation depends on the characteristics of local file system. Don’t use file buffer on remote file system, e.g. NFS, GlusterFS, HDFS and etc. We observed major data loss by using remote file system.
