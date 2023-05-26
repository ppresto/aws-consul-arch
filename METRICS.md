# AWS Consul - Deploy Metrics Stack Prometheus-Grafana-Fortio

## PreReq
* Provision EKS Cluster and connect
* Deploy Consul Server
* kubectl
* helm
## Deploy the monitoring stack with Helm
Current Monitoring Stack:
* prometheus
* prometheus-consul-exporter
* grafana

```
metrics/deploy_helm.sh
```

## Deploy Fortio for load testing
There are multiple test cases contained within the `fortio-tests` directory.

Deploy fortio test cases
```
metrics/fortio-tests/deploy.sh
```

Undeploy test cases by providing any value as a parameter (ex: delete)
```
metrics/fortio-tests/deploy.sh delete
```

## Fortio Quickstart
* -j enables json output to stdout which is needed by -f. Otherwise, use `kubectl port-forward deploy/fortio 8080` to view graphs.
* -f write output to file_path. Requires -j
* -k k8s-context to override current-context
* -d 10 duration of test
* -q 1000 Queries per second
* -c 2 connections array. If not provided connections=(2 4 8 16 32 64)
* -w 0 no recovery time b/w tests 
* -h "KEY:VALUE" Add a Header
* -p 512  Payload in bytes

HTTP Test Examples
```
fortio_cli.sh -t consul_http -n fortio-consul-optimized -d60 -c2
fortio_cli.sh -j -t consul_http -n fortio-consul-optimized -k usw2-app1 -d300 -p512 -f ./reports
fortio_cli.sh -j -t consul_http -n fortio-consul-optimized -q1000 -d120 -h "MY_CUSTOM_REQ_HEADER:XXXXXXXXXXXXXX" -f ./reports -c "4 8 16"
```

GRPC Test Examples
```
fortio_cli.sh -t consul_grpc -n fortio-consul-optimized -k usw2-app1 -d300 -c "2 4 8"
fortio_cli.sh -j -t consul_grpc -n fortio-consul-optimized -d300 -c2 -p512 -h "MY_CUSTOM_REQ_HEADER:XXXXXXXXXXXXXX" -f ./reports
```
## Run All Fortio Tests
The fortio_cli.sh wrapper helps run fortio test cases quickly from the CLI and write the data to a file.  The following wrapper scripts use fortio_cli.sh to run a suite of tests.
* parallel_http_tests.sh
* seq_http_tests.sh
* parallel_grpc_tests.sh
* seq_http_tests.sh

### Parallel - parallel_http_tests.sh
Runs all test cases in parallel. 
* fortio-baseline
* fortio-consul-default
* fortio-consul-optimized
* fortio-consul-logs
* fortio-consul-l7
These scripts will use your current k8s context for 6 different runs across all test cases.  Each run uses a higher # of concurrent connections or threads (2, 4, 8, 16, 32, 64).  The default test duration is 300 seconds per test.  

```
parallel_http_tests.sh -k usw2-app1 -f ./reports -p1024 -c2
parallel_grpc_tests.sh -k usw2-app1 -f ./reports -d30 -h "KEY:VALUE"
```
### Sequencial - seq_http_tests.sh
Runs all test cases in sequence.
* fortio-baseline
* fortio-consul-default
* fortio-consul-optimized
* fortio-consul-logs
* fortio-consul-l7
This script will use your current k8s context for 6 different runs on each test case in order.  Each run uses a higher # of concurrent connections or threads (2, 4, 8, 16, 32, 64).  The default test duration is 300 seconds per test.  This gives the most accurate results and takes ~ 3h.
```
seq_http_tests.sh -k usw2-app1 -f ./reports -p1024 -c2
seq_grpc_tests.sh -k usw2-app1 -f ./reports -d30 -h "KEY:VALUE"
```
## Run Fortio Test using fortio_cli.sh
https://istio.io/v1.14/docs/ops/deployment/performance-and-scalability/

```

```

### Run a single HTTP/GRPC performance test and write results to a file

`fortio-consul-optimized` has configured the dataplane with more cpu and memory then `fortio-consul-default` to support more conncurrent connections.  Use either test case to run a quick HTTP performance test.
```
metrics/reports/fortio_cli.sh -j -t consul_http -n fortio-consul-optimized -k usw2-app1 -d 10 -w 0 -c2 -f /tmp

../../metrics/reports/fortio_cli.sh -j -t consul_http -n fortio-consul-optimized -k usw2-app1 -d300 -p1024 -c16 -f ./reports
```

single GRPC test
```
metrics/reports/fortio_cli.sh -j -t consul_grpc -n fortio-consul-optimized -d 10 -w0 -c2 -f /tmp
```

### Run a single test and use fortio UI to view results
By removing the -j option the report will not be written to stdout and live within the fortio-client container.
```
metrics/reports/fortio_cli.sh -t consul_http -n fortio-consul-optimized -d 10 -w 0 -c2
```
Once the test completes open the fortio UI in your browser.  
```
kubectl -n fortio-consul-optimized port-forward deploy/fortio-client 8080:8080
```
Go to http://localhost:8080/fortio
Run additional tests from the UI or Click on "Browse `saved results` (or `raw JSON`)" to view this last report.


### Run an HTTP performance test using L7 Intentions
The `fortio-consul-logs` test case sets proxy-defaults to enable the envoy access log and capture additional custom headers like "MY_CUSTOM_REQ_HEADER".  The `fortio-consul-l7` test case uses a l7 intention to verify all requests have this custom header set.  Use the `fortio-consul-l7` to run a successful and failed test to verify the l7 intention is working as expected.
* Open tab 1 - tail the envoy access logs
* Open tab 2 - run the `fortio-consul-l7` test.

Tab 1: Run successful test with correct header
```
metrics/reports/fortio_cli.sh -j -t consul_http -n fortio-consul-l7 -d 10 -w 0 -c2 -h "MY_CUSTOM_REQ_HEADER:Value" -f /tmp
```

Tab 2: Tail envoy access log
```
kubectl -n fortio-consul-l7 logs deploy/fortio-server-defaults -c consul-dataplane -f
```
Look for the `MY_CUSTOM_REQ_HEADER`, and verify you see a successful response `"response_code":200`. Keep this log tailing...


Next, go back to Tab 1 and run a failed test using a bad header.
```
metrics/reports/fortio_cli.sh -j -t consul_http -n fortio-consul-l7 -d 10 -w 0 -c2 -h "MY_BAD_HEADER:Value" -f /tmp
```
While running this test, watch the envoy access logs for a permission denied response `"response_code":403`.  The requests to look for are coming from `"user_agent":"fortio.org/fortio-1.54.2"`


### Fortio Notes

Reports
```
fortio report -data-dir ./reports/
```

GRPC
```
kubectl exec -it deploy/fortio-client -- fortio load -a -grpc -ping -grpc-ping-delay 0.25s -payload "01234567890" -c 2 -s 4 -json - fortio-server-defaults-grpc:8079

kubectl exec -it deploy/fortio-client -- fortio load -grpc -ping -qps 100 -c 10 -r .0001 -t 3s -labels "grpc test" fortio-server-defaults-grpc:8079

# -s multiple streams per -c connection.  .25s delay in replies using payload of 10bytes
kubectl exec -it deploy/fortio-client -- fortio load -a -grpc -ping -grpc-ping-delay 0.25s -payload "01234567890" -c 2 -s 4 fortio-server-defaults-grpc:8079
```

HTTP
* `-json -` write json output to stdout
```
kubectl -n fortio-baseline exec -it deploy/fortio-client -- fortio load -qps 1000 -c 32 -r .0001 -t 300s -labels "http test" -json - http://fortio-server-defaults:8080/echo
```

TCP
```
fortio load -qps -1 -n 100000 tcp://localhost:8078
```

UDP
```
fortio load -qps -1 -n 100000 udp://localhost:8078/
```

Run fortio HTTP load test directly against pod
```
kubectl exec -it fortio-client-6b78f9c56c-hxzjk -- fortio load -qps 100 -c 10 -r .0001 -t 3s -labels "http test" http://fortio-server-defaults:8080/echo
```

Run fortio GRPC load test directly against pod
```
kubectl exec -it fortio-client-6b78f9c56c-hxzjk -- fortio load -grpc -ping -qps 100 -c 10 -r .0001 -t 3s -labels "grpc test" fortio-server-defaults:8079
```

run curl (add injector)
```
kubectl run -i --rm --restart=Never dummy --image=dockerqa/curl:ubuntu-trusty --command -- curl --silent httpbin:8000/html
```
