# Open Telemetry Django Python Import Bug

Minimal reproduction case for https://github.com/open-telemetry/opentelemetry-operator/issues/2302

## Setup

```shell
./create_cluster.sh  # create cluster using kind, install cert-manager, opentelemetry operator
kubectl apply -f pod-otel-installed.yml,pod-otel-operator.yml
```

### Tests

```shell
# Import a normal Python module
kubectl exec django-uses-operator -- python manage.py shell -c 'import vanilla.bean'  # WORKS

# Import a normal Python module which defines a Django model
kubectl exec django-uses-operator -- python manage.py shell -c 'import pears.models'  # FAILS

# Same as above, but prepend /app to PYTHONPATH
kubectl exec django-uses-operator -- sh -c 'env PYTHONPATH="/app:$PYTHONPATH" python manage.py shell -c "import pears.models"'  # FAILS

# Same as above, but unset PYTHONPATH
kubectl exec django-uses-operator -- sh -c 'env PYTHONPATH= python manage.py shell -c "import pears.models"'  # WORKS

# Functionally the same as above, explicit PYTHONPATH
kubectl exec django-uses-operator -- sh -c 'env PYTHONPATH="/app" python manage.py shell -c "import pears.models"'  # WORKS
```

Error message for failing test cases:

```
RuntimeError: Model class pears.models.Pear doesn't declare an explicit app_label and isn't in an application in INSTALLED_APPS.
```

```shell
# not using otel operator
kubectl exec django-uses-installed -- python manage.py shell -c 'import pears.models'  # WORKS

# manual usage of autoinstrumentation, without otel operator
kubectl exec django-uses-installed -- opentelemetry-instrument --traces_exporter console,otlp --metrics_exporter console --service_name pearfarm --exporter_otlp_endpoint https://example.com python manage.py shell -c 'import pears.models'  # FAILS
 
 # manual usage of autoinstrumentation, but unset PYTHONPATH
kubectl exec django-uses-installed -- sh -c 'opentelemetry-instrument --traces_exporter console,otlp --metrics_exporter console --service_name pearfarm --exporter_otlp_endpoint https://example.com env PYTHONPATH= python manage.py shell -c "import pears.models"'  # WORKS
```

Same error message as before.

### Tear Down

```shell
kind delete cluster
```

## Notes to self

I used these commands to build the images.

```shell
docker buildx build -t docker.io/jennydaman/djangoexamplepear:latest --push .
docker buildx build -t docker.io/jennydaman/djangoexamplepear:otel --build-arg otel=y --push .
```
