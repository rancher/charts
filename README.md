# Rancher Charts
Catalog Charts for Rancher 2.0


## Catalogs
Rancher catalog builds on an enhanced version of Helm. All upstream Helm charts can work on Rancher, but Rancher adds several enhancements to make the user experience better.

## Catalog Git Repositories
Rancher stores Helm charts in git repositories to expedite the fetch and update of charts. In Rancher 2.0, only global catalogs are supported. Support for cluster-level and project-level charts will be added in the future.

#### 1. How to add a custom catalog
You can define your own additional custom catalog sources in the `Global->Catalogs` menu. Each one needs a unique name and a URL that git clone can handle (see [docs](https://git-scm.com/docs/git-clone#_git_urls_a_id_urls_a) for more info).

one git repository can have multiple charts using different names and version.

#### 2. How often do we refresh the catalog
The auto refresh period is 5 minutes, but you can click the `refresh` button in the Catalog Apps page to get instant update.


## Enhanced Revision Tracking
While Helm supports versioned deployments, Rancher added capabilities to track and display what exactly changed between different revisions.

#### 1. is multi-version supported in the Rancher Catalog
Rancher uses sub-path and version specified in the `Chart.yaml` for multi-versionn support.

## Streamlined Application Launch
Rancher supports simplified README files and questions files to streamline the application launch process. Users need not read through the entire list of Helm variables to understand how to launch an application.

## Application Resource Management
Rancher tracks all the resources created by a specific application. Users can easily navigate and troubleshoot on a page listing all the workload objects used to power an application.

## How to Contribute
1. Rancher currently supports [helm](https://docs.helm.sh/) chart, you can create your own chart using `helm create`.
2. Rancher also supports `helm dependency` to manage a chart's dependencies. You must have `requirements.yaml` in your chart directory and run build before deploy to the Rancher Catalog. For more details please reference [helm docs](https://github.com/kubernetes/helm/blob/master/docs/helm/helm_dependency.md).
2. You can add `app-readme.md` file to specify a simplified README in the Launch page.
3. Rancher uses the `questions.yaml` to specify the catalog chart UI designs of questions, it streamlines the application launch process. Users need not read through the entire list of Helm variables to understand how to launch an application. 


#### Current Supported Question Variables

| Variable  | Type | Description |
| ------------- | ------------- |------------- |
| 	variable          | string        |  define the variable name specified in the `values.yaml`file, using `foo.bar` for nested object. <br> `json:"variable,required" yaml:"variable, required"` |
| 	label             | string        |  define the UI label. <br>`json:"label,required" yaml:"label,required"` |
| 	description       | string        |  specify the description of the variable.<br>`json:"description,omitempty" yaml:"description,omitempty"` |
| 	type              | string        |  default to `string` if not specified (current supported types are string, boolean, int, enum, password, storageclass and hostname).  <br>`json:"type,omitempty" yaml:"type,omitempty"` |
| 	required          | bool          |  define if the variable is required or not (true \| false)<br>`json:"required,omitempty" yaml:"required,omitempty"` |
| 	default           | string        |  specify the default value. <br>`json:"default,omitempty" yaml:"default,omitempty"` |
| 	group             | string        |  group questions by input value. <br>`json:"group,omitempty" yaml:"group,omitempty"` |
| 	min_length        | int           | min character length. <br>`json:"minLength,omitempty" yaml:"min_length,omitempty"` |
| 	max_length        | int           | max character length. <br>`json:"maxLength,omitempty" yaml:"max_length,omitempty"` |
| 	min               | int           |  min integer length. <br>`json:"min,omitempty" yaml:"min,omitempty"` |
| 	max               | int           |  max integer length. <br>`json:"max,omitempty" yaml:"max,omitempty"` |
| 	options           | []string      |  specify the options when the vriable type is `enum`, for example <br>options:<br> - "ClusterIP" <br> - "NodePort" <br> - "LoadBalancer" <br>`json:"options,omitempty" yaml:"options,omitempty"` |
| 	valid_chars       | string        |  regular expression for input chars validation. <br>`json:"validChars,omitempty" yaml:"valid_chars,omitempty"` |
| 	invalid_chars     | string        |  regular expression for invalid input chars validation. <br>`json:"invalidChars,omitempty" yaml:"invalid_chars,omitempty"` |
| 	subquestions      | []subquestion |  add an array of subquestions. <br>`json:"subquestions,omitempty" yaml:"subquestions,omitempty"` |
| 	show_if           | string        | show current variable if conditional variable is true, for example `show_if: "serviceType=Nodeport"` <br>`json:"showIf,omitempty" yaml:"show_if,omitempty"` |
| 	show\_subquestion_if |  string       | show subquestions if is true or equal to one of the options. for example `show_subquestion_if: "true"` <br>`json:"showSubquestionIf,omitempty" yaml:"show_subquestion_if,omitempty"` |

**subquestions**: subquestions[] cannot contain subquestions and show\_subquestions_if variable, but all other variables in the above are supported. 

**categories**: specify chart categories for filtering in the following format and added to the `questions.yaml` file.

```
categories:
- Blog
- CMS
```





## License
Copyright (c) 2018 [Rancher Labs, Inc.](http://rancher.com)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
