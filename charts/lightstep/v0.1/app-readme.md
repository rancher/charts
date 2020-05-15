# Lightstep

[Lightstep](https://lightstep.com/) is an observability platform designed to help you understand deep systems and identify the problems that arise within them quickly. This chart deploys a [Lightstep satellite](https://docs.lightstep.com/docs/learn-about-satellites) which receives telemetry data from your systems and makes it available to query and eventually persist in Lightstep's SaaS.


## Configuration:

In order to configure the satellite appropriately, please consult https://docs.lightstep.com/docs/satellite-configuration-parameters.  If you have questions, or need some human help, please contact support@lightstep.com.


## Usage
This will run a Lightstep satellite within Rancher. The satellite by default will expose several different ports for sending data to them.  Please refer to the [satellite configuration](https://docs.lightstep.com/docs/satellite-configuration-parameters#ports)