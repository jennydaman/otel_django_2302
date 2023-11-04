#!/bin/bash -ex

kind create cluster

kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.2/cert-manager.yaml
kubectl rollout status -n cert-manager deployment cert-manager-webhook --timeout=2m

kubectl apply -f https://github.com/open-telemetry/opentelemetry-operator/releases/download/v0.88.0/opentelemetry-operator.yaml
kubectl rollout status -n opentelemetry-operator-system deployment opentelemetry-operator-controller-manager --timeout=2m

kubectl apply -f - << EOF
apiVersion: opentelemetry.io/v1alpha1
kind: Instrumentation
metadata:
  name: instrumentation
spec:
  exporter:
    endpoint: https://example.com
  propagators:
    - tracecontext
    - baggage
  sampler:
    type: parentbased_traceidratio
    argument: "1"
EOF
