
#!/bin/bash
../../../../terraform-aws-azure-load-test/deploy/reports/run.sh  -j -t baseline_http -n fortio-baseline -d300 -w30
../../../../terraform-aws-azure-load-test/deploy/reports/run.sh  -j -t baseline_grpc -n fortio-baseline -d300 -w30
../../../../terraform-aws-azure-load-test/deploy/reports/run.sh  -j -t consul_http -n fortio-consul-100 -d300 -w30
../../../../terraform-aws-azure-load-test/deploy/reports/run.sh  -j -t consul_grpc -n fortio-consul-100 -d300 -w30
../../../../terraform-aws-azure-load-test/deploy/reports/run.sh  -j -t consul_http -n fortio-consul-150 -d300 -w30
../../../../terraform-aws-azure-load-test/deploy/reports/run.sh  -j -t consul_grpc -n fortio-consul-150 -d300 -w30
../../../../terraform-aws-azure-load-test/deploy/reports/run.sh  -j -t consul_http -n fortio-consul-logs -d300 -w30
../../../../terraform-aws-azure-load-test/deploy/reports/run.sh  -j -t consul_grpc -n fortio-consul-logs -d300 -w30