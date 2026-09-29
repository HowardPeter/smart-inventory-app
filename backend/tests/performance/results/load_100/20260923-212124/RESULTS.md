# load_100 — Performance Test

## 1. Test Overview

| Item                        | Value                                                                                                                  |
| --------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| Scenario                    | `load_100`                                                                                                             |
| Endpoint                    | `GET /api/inventories`                                                                                                 |
| Virtual Users               | `100`                                                                                                                  |
| Ramp-up                     | `120 seconds`                                                                                                          |
| Duration                    | `300 seconds`                                                                                                          |
| Think Time                  | `10–25 seconds`                                                                                                        |
| Test Tool                   | Apache JMeter                                                                                                          |
| Environment                 | AWS `ap-southeast-1`                                                                                                   |
| Lambda Reserved Concurrency | Account concurrency quota was increased before this run; exact applied quota value was not recorded in the test output |
| API Gateway Throttle        | Not recorded in this test result                                                                                       |

---

## 2. JMeter Result

| Metric                |        Result |
| --------------------- | ------------: |
| Total Requests        |       `1,613` |
| Error Count           |           `0` |
| Error Rate            |       `0.00%` |
| Average Response Time |   `566.57 ms` |
| Median                |      `351 ms` |
| P90                   |   `929.80 ms` |
| P95                   | `1,405.90 ms` |
| P99                   | `4,690.30 ms` |
| Maximum               |   `10,658 ms` |
| Throughput            |  `5.57 req/s` |

---

## 3. CloudWatch Metrics Result

### Lambda

| Metric                    |        Result |
| ------------------------- | ------------: |
| Invocations               |       `1,613` |
| Errors                    |           `0` |
| Throttles                 |           `0` |
| Max Concurrent Executions |          `38` |
| Average Duration          | `300.87 ms`\* |
| Maximum Duration          | `5,044.68 ms` |

\* Average Lambda duration is the value reported for the `21:22` minute
in the collected CloudWatch data. The CloudWatch output contains
multiple one-minute datapoints; the reported averages ranged from
approximately `155.03 ms` to `1,550.26 ms`, with the initial minute
showing the highest average due to startup activity.

### API Gateway

| Metric          |        Result |
| --------------- | ------------: |
| Requests        |       `1,613` |
| Average Latency | `312.98 ms`\* |
| Maximum Latency |    `5,232 ms` |
| 4XX Errors      |           `0` |
| 5XX Errors      |           `0` |

\* The reported API Gateway average latency varied by one-minute
datapoint. The `21:22` datapoint was `312.98 ms`; the initial `21:21`
minute reached `1,606.36 ms` on average.

---

## 4. Analysis

- The test completed **1,613 requests with 0 errors**, giving a **0.00%
  application-level error rate** in JMeter.
- This is a significant improvement compared with the earlier `load_100`
  runs where the Lambda account concurrency quota of `10` caused Lambda
  throttling and downstream `503` responses. After increasing the AWS
  account concurrency quota, the test recorded **0 Lambda throttles**
  and **0 API Gateway 5XX errors**.
- Lambda concurrency reached **38**, demonstrating that the previous
  concurrency ceiling of `10` was no longer limiting this test. The
  workload was able to scale beyond the previous quota without being
  throttled.
- Most requests completed relatively quickly: median response time was
  **351 ms**, P90 was **929.8 ms**, and P95 was **1.41 s**.
- The main remaining performance concern is the **long-tail latency**.
  P99 increased to **4.69 s**, while the maximum JMeter response time
  reached **10.66 s**.
- CloudWatch shows elevated latency during the initial test period. The
  first minute reported an average Lambda duration of approximately
  **1.55 s** and a maximum of **5.04 s**. API Gateway latency for the
  same period averaged approximately **1.61 s**, with a maximum of
  **5.23 s**.
- Because API Gateway `IntegrationLatency` closely follows API Gateway
  `Latency`, the observed delay is primarily associated with the Lambda
  integration rather than API Gateway’s own overhead.
- The initial high Lambda duration is consistent with startup/cold-start
  behavior being present in the serverless workload. However, the
  available metrics alone do not prove that the single **10.66 s**
  JMeter maximum was exclusively a cold start; it should be investigated
  against individual request timestamps and Lambda logs.
- The absence of throttles and 5XX responses indicates that **AWS
  account concurrency was no longer the immediate bottleneck for this
  test**.
- The test therefore shifts the investigation from **capacity blocked by
  the account concurrency quota** to **tail latency and startup behavior
  under load**.

---

## 5. Conclusion

The `load_100` scenario successfully handled **100 virtual users** with
**1,613 requests, 0 errors, and 0 Lambda throttles** after the AWS
account concurrency quota was increased.

The previous `10` concurrent-execution limit was demonstrated to be an
infrastructure-level bottleneck in earlier tests. In this run, Lambda
reached **38 concurrent executions** without throttling, confirming that
the increased quota removed that specific constraint for the tested
workload.

The system’s normal response performance is acceptable for this test
profile, with a **351 ms median** and **929.8 ms P90**. However, the
test still shows a significant **tail-latency problem**: **P99 = 4.69
s** and **maximum = 10.66 s**. The initial period also shows elevated
Lambda duration, suggesting that Lambda startup/cold-start behavior
remains an area for investigation.
