# Charts Testing

### Lint Testing

Lint testing is performed on every pull request and is run by the Drone CI. The
configuration is stored in the [`test/ct.yaml`](/test/ct.yaml) file.

The Lint Testing currently:

* Performs [`ct lint`](https://github.com/guangbochen/chart-testing) on any changed charts to provide quick feedback


#### Run Lint Testing Locally

##### Using Docker Images:

```
docker run -d -it --name chart-test -v /path/to/your/charts/:/workdir/charts guangbo/chart-testing:v2.0.2-rancher1
docker exec -it chart-test sh 
cd workdir/charts/
git remote add rancher-charts https://github.com/rancher/charts
git fetch rancher-charts master
ct lint --config test/ct.yaml
```

##### Using Binary Build:

You can download the [binary build](https://github.com/guangbochen/chart-testing/releases/tag/v2.0.2-rancher1) and run it locally using:

```
ct lint --config /path/to/your/charts/test/ct.yaml
```
