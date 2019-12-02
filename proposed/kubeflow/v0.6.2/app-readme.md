# Kubeflow

The Kubeflow project is dedicated to making deployments of machine learning (ML) workflows on Kubernetes simple, portable and scalable. Our goal is not to recreate other services, but to provide a straightforward way to deploy best-of-breed open-source systems for ML to diverse infrastructures. Anywhere you are running Kubernetes, you should be able to run Kubeflow

## Requirements

Kubeflow need some requirements in order to work properly:
- Kubeflow 0.6 is just compatible with k8s 1.14 and 1.15. [Compatibility table](https://www.kubeflow.org/docs/started/k8s/overview/#minimum-system-requirements)
- Istio with ingress gateway should be deployed or enabled on k8s cluster.
- Storageclass should be configured on k8s cluster to enable persistence volumes

## Who should consider using Kubeflow?

Based on the current functionality you should consider using Kubeflow if:

- You want to train/serve TensorFlow models in different environments (e.g. local, on prem, and cloud)
- You want to use Jupyter notebooks to manage TensorFlow training jobs
- You want to launch training jobs that use resources – such as additional CPUs or GPUs – that aren’t available on your personal computer
- You want to combine TensorFlow with other processes
  > For example, you may want to use [tensorflow/agents](https://github.com/google-research/batch-ppo) to run simulations to generate data for training reinforcement learning models.

## How it works?

For more details of how Kubeflow works please reference the [Kubeflow Doc](https://www.kubeflow.org/docs/about/kubeflow/).
