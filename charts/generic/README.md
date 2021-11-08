# Generic

A chart instantiation of k8s@home's fantastic [common library chart](https://docs.k8s-at-home.com/our-helm-charts/common-library/). This allows easy deployment of simple applications without the need to create or maintain a separate chart.

# Overrides
There are a few behaviors that are overridden from the `common` library chart. Each change is
made with the goal of having the release definition fully define the resulting manifests, like
a new chart definition:
1. Manifest names default to the release name instead of this chart name
2. All optional manifests are opt-in
3. Image `tag` and `pullPolicy` are optional
4. A `metrics` port is available
