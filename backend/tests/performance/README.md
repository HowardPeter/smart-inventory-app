# SIS Phase 1 — Load & Availability Tests

This directory contains reproducible JMeter-based load tests for the SIS backend.

## Scope

Phase 1 measures:

- baseline latency and throughput
- behavior under increasing concurrent users
- request errors and timeouts
- API Gateway 429/throttling behavior
- Lambda throttling/concurrency behavior
- controlled RPS limits
- degradation during sustained load

Run these tests against **staging only**.

## Directory

```text
performance/
├── config/
│   └── load-test.yml
├── jmeter/
│   ├── read-only-load.jmx
│   └── rps-load.jmx
├── scripts/
│   ├── run-phase1.sh
│   └── run-all.sh
├── results/
└── README.md
```

## 1. Install JMeter

JMeter 5.6.x is expected.

Verify:

```bash
jmeter --version
```

## 2. Configure the target

Do not put secrets in Git.

The YAML file documents the intended test matrix. Runtime target values are supplied through environment variables:

```bash
export SIS_TEST_HOST="your-staging-api-host"
export SIS_TEST_ENDPOINT="/your/read-only-endpoint"
export SIS_TEST_TOKEN="your-staging-access-token"
```

Example:

```bash
export SIS_TEST_HOST="staging-api.example.com"
export SIS_TEST_ENDPOINT="/api/inventory"
export SIS_TEST_TOKEN="..."
```

The endpoint above is only an example. Replace it with an actual read-only SIS endpoint.

## 3. Run one scenario

```bash
./scripts/run-phase1.sh baseline
```

Then progressively:

```bash
./scripts/run-phase1.sh load_100
./scripts/run-phase1.sh load_200
./scripts/run-phase1.sh load_500
./scripts/run-phase1.sh load_1000
```

## 4. RPS tests

```bash
./scripts/run-phase1.sh rps_100
./scripts/run-phase1.sh rps_200
./scripts/run-phase1.sh rps_500
./scripts/run-phase1.sh rps_1000
```

The RPS scenarios use JMeter's Constant Throughput Timer.

The requested RPS is an offered-load target; actual achieved throughput must be checked in the JMeter report.

## 5. Sustained load

```bash
./scripts/run-phase1.sh sustained
```

Current configuration:

- 300 concurrent users
- 180-second ramp-up
- 30-minute duration

This is intended to reveal degradation over time rather than a short peak.

## 6. Results

Each execution creates:

```text
results/
└── <scenario>/
    └── <timestamp>/
        ├── results.jtl
        ├── html-report/
        └── metadata.txt
```

Do not commit large raw `.jtl` files or generated HTML reports unless you intentionally want them as benchmark artifacts.

## 7. CloudWatch observation

During every test, record the corresponding AWS metrics for:

### API Gateway

- Count
- 4XX
- 5XX
- Latency
- IntegrationLatency

Pay particular attention to HTTP 429 responses.

### Lambda

- Invocations
- Duration
- Errors
- Throttles
- ConcurrentExecutions

The purpose is to distinguish:

```text
API Gateway throttling
        vs
Lambda throttling
        vs
application errors/timeouts
        vs
backend/database degradation
```

## 8. What to record

For each scenario record at minimum:

| Metric     | Meaning                    |
| ---------- | -------------------------- |
| Requests   | Total requests             |
| Throughput | Actual requests/sec        |
| Error %    | Failed requests            |
| p50        | Median latency             |
| p90        | High-percentile latency    |
| p95        | Main performance indicator |
| p99        | Tail latency               |
| Max        | Worst observed latency     |
| HTTP 429   | Gateway/rate-limit signal  |
| HTTP 5xx   | Server-side failure signal |
| Timeout    | Availability signal        |

Also record Lambda/API Gateway metrics from CloudWatch.

## 9. Interpretation

Do not define success as "the system reached 1000 users".

Instead identify the point where one or more of these begin to degrade materially:

```text
latency ↑
error rate ↑
timeouts ↑
HTTP 429 ↑
Lambda throttles ↑
API Gateway 5xx ↑
```

Then correlate the JMeter result with CloudWatch metrics to determine the likely limiting layer.

## 10. Recommended execution order

Start with:

```text
baseline
  ↓
load_100
  ↓
load_200
  ↓
load_500
  ↓
load_1000
```

Only continue to higher load if the staging environment remains useful and stable.

Then run:

```text
rps_100
  ↓
rps_200
  ↓
rps_500
  ↓
rps_1000
```

Finally:

```text
sustained
```

Do not run `run-all.sh` blindly against an unverified staging environment. First validate the endpoint with the baseline test.

## Security

Never commit:

- access tokens
- refresh tokens
- passwords
- service-account JSON
- production credentials
- generated result files containing sensitive response data

The test runner receives the access token through `SIS_TEST_TOKEN`.
