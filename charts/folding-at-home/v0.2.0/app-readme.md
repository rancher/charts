# Folding@home for Kubernetes

This is a Helm chart that deploys Folding@home clients as Kubernetes pods. It supports both CPU and GPU modes. Use of GPU requires the necessary drivers and Kubernetes configuration.

Recently, Folding@home prioritized workloads for COVID-19 virus research. By running this workload you can donate excess compute resources to the research efforts of scientists around the world. Read more about it here: https://foldingathome.org/2020/02/27/foldinghome-takes-up-the-fight-against-covid-19-2019-ncov/

## Options
By default this chart will deploy with CPU mode only. If you enable in the chart options, it will enable GPU and CPU computation.

You can also limit resources that can be consumed by these pods by adjusting the CPU and Memory limits in the chart values.

If you want your donation to be credited towards a team, you can enter your team details in the Folding @ Home Team Info section.

This chart is based on the work of @richstokes: https://github.com/richstokes/k8s-fah.
