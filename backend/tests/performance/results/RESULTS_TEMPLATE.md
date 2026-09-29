# <Scenario Name> — Performance Test

## 1. Test Overview

| Item                        | Value                  |
| --------------------------- | ---------------------- |
| Scenario                    | `<scenario>`           |
| Endpoint                    | `<method> <endpoint>`  |
| Virtual Users               | `<users>`              |
| Ramp-up                     | `<ramp-up>`            |
| Duration                    | `<duration>`           |
| Think Time                  | `<think-time>`         |
| Test Tool                   | Apache JMeter          |
| Environment                 | `<environment>`        |
| Lambda Reserved Concurrency | `<value>`              |
| API Gateway Throttle        | `<rate> RPS / <burst>` |

---

## 2. JMeter Result

| Metric                |          Result |
| --------------------- | --------------: |
| Total Requests        |       `<value>` |
| Error Count           |       `<value>` |
| Error Rate            |      `<value>%` |
| Average Response Time |    `<value> ms` |
| Median                |    `<value> ms` |
| P90                   |    `<value> ms` |
| P95                   |    `<value> ms` |
| P99                   |    `<value> ms` |
| Maximum               |    `<value> ms` |
| Throughput            | `<value> req/s` |

---

## 3. CloudWatch Metrics Result

### Lambda

| Metric                    |       Result |
| ------------------------- | -----------: |
| Invocations               |    `<value>` |
| Errors                    |    `<value>` |
| Throttles                 |    `<value>` |
| Max Concurrent Executions |    `<value>` |
| Average Duration          | `<value> ms` |
| Maximum Duration          | `<value> ms` |

### API Gateway

| Metric          |       Result |
| --------------- | -----------: |
| Requests        |    `<value>` |
| Average Latency | `<value> ms` |
| Maximum Latency | `<value> ms` |
| 4XX Errors      |    `<value>` |
| 5XX Errors      |    `<value>` |

---

## 4. Analysis

- `<Describe the observed behavior.>`
- `<Correlate JMeter results with CloudWatch metrics.>`
- `<Identify the bottleneck, limitation, or failure cause.>`
- `<Mention any relevant observations such as throttling, cold starts, latency spikes, etc.>`

---

## 5. Conclusion

`<Summarize the result of the test.>`

`<State the main limitation or finding.>`

`<State the next experiment or change to investigate, if applicable.>`
