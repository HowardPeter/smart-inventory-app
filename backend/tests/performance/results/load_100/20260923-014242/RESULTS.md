# Load 100 - Performance Test

## 1. Test Overview

| Item          | Value                  |
| ------------- | ---------------------- |
| Scenario      | `load-100`             |
| Endpoint      | `GET /api/inventories` |
| Virtual Users | 100                    |
| Ramp-up       | 60s                    |
| Duration      | 300s                   |
| Think Time    | 10–25s                 |
| Test Tool     | Apache JMeter          |
| Environment   | AWS Staging            |

---

## 2. JMeter Result

| Metric                |      Result |
| --------------------- | ----------: |
| Total Requests        |       1,620 |
| Error Count           |          24 |
| Error Rate            |       1.48% |
| Average Response Time |   430.90 ms |
| Median                |   302.50 ms |
| P90                   |   711.90 ms |
| P95                   |    1,013 ms |
| P99                   | 1,843.58 ms |
| Maximum               |    5,328 ms |
| Throughput            |  5.58 req/s |

---

## 3. CloudWatch Metrics Result

### Lambda

| Metric                    |   Result |
| ------------------------- | -------: |
| Invocations               |    1,596 |
| Errors                    |        0 |
| Throttles                 |       24 |
| Max Concurrent Executions |       10 |
| Max Duration              | 4,574 ms |

### API Gateway

| Metric          |    Result |
| --------------- | --------: |
| Requests        |     1,620 |
| Average Latency |   ~230 ms |
| Maximum Latency | ~4,725 ms |
| 4XX Errors      |         - |
| 5XX Errors      |         - |

---

## 4. Analysis

- The test generated **100 virtual users**, but the 10–25s think time reduced the actual request rate to approximately **5.58 req/s**.
- The initial burst reached the Lambda **reserved concurrency limit of 10**.
- Lambda throttling occurred during the initial burst, which correlated with the errors observed by JMeter.
- After the initial burst, concurrency remained below the limit and the system became more stable.
- The high maximum latency was mainly observed during the initial burst/cold-start period.
- Therefore, **100 virtual users does not mean 100 concurrent Lambda executions**; the workload shape and think time significantly affect actual Lambda concurrency.

---

## 5. Conclusion

The system handled the steady-state workload of approximately **5.58 req/s** with low error rates after the initial burst.

The main limitation identified in this test was the **Lambda reserved concurrency of 10**, which was reached during the initial burst and resulted in throttling and request failures.

Further testing should evaluate different Lambda concurrency limits and workload shapes to determine the system's sustainable capacity.
