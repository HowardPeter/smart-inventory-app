Ghi nhận các lỗi:

```
error: ThrottlingException: Rate exceeded. Ensure you have the high-throughput setting enabled for higher limits: https://docs.aws.amazon.com/systems-manager/latest/userguide/parameter-store-throughput.html
      at AwsJson1_1Protocol.handleError (/var/task/node_modules/@aws-sdk/core/dist-cjs/submodules/protocols/index.js:809:27)
      at process.processTicksAndRejections (node:internal/process/task_queues:103:5)
      at async AwsJson1_1Protocol.deserializeResponse (/var/task/node_modules/@smithy/core/dist-cjs/submodules/protocols/index.js:529:13)
      at async /var/task/node_modules/@smithy/core/dist-cjs/submodules/schema/index.js:23:24
      at async /var/task/node_modules/@smithy/core/dist-cjs/index.js:118:20
      at async /var/task/node_modules/@smithy/core/dist-cjs/submodules/retry/index.js:170:50
      at async /var/task/node_modules/@aws-sdk/core/dist-cjs/submodules/client/index.js:125:26
      at async getParameterValues (file:///var/task/dist/common/utils/get-aws-ssm-parameter.js:29:18)
      at async loadApiSecrets (file:///var/task/dist/common/utils/get-aws-ssm-parameter.js:95:24)
      at async loadApiSecretsToEnvironment (file:///var/task/dist/common/utils/get-aws-ssm-parameter.js:149:21) {
    '$fault': 'client',
    '$retryable': undefined,
    '$metadata': {
      httpStatusCode: 400,
      requestId: 'f3830f5c-8fda-46f5-95b9-bf3e3378c306',
      extendedRequestId: undefined,
      cfId: undefined,
      attempts: 3,
      totalRetryDelay: 984
    },
    QuotaCode: undefined,
    ServiceCode: undefined,
    __type: 'ThrottlingException'
  }
```

```
2026-09-26T14:51:31.537+07:00
{
    "level": 50,
    "time": 1790409091537,
    "service": "backend",
    "err": {
        "type": "DriverAdapterError",
        "message": "(EMAXCONN) max client connections reached, limit: 200: (EMAXCONN) max client connections reached, limit: 200",
        "stack": "DriverAdapterError: (EMAXCONN) max client connections reached, limit: 200\n    at PrismaPgAdapter.onError (file:///var/task/node_modules/@prisma/adapter-pg/dist/index.mjs:651:11)\n    at PrismaPgAdapter.performIO (file:///var/task/node_modules/@prisma/adapter-pg/dist/index.mjs:646:12)\n    at process.processTicksAndRejections (node:internal/process/task_queues:103:5)\n    at async PrismaPgAdapter.queryRaw (file:///var/task/node_modules/@prisma/adapter-pg/dist/index.mjs:566:30)\n    at async e.interpretNode (/var/task/node_modules/@prisma/client/runtime/client.js:11:44573)\n    at async e.interpretNode (/var/task/node_modules/@prisma/client/runtime/client.js:11:45017)\n    at async e.interpretNode (/var/task/node_modules/@prisma/client/runtime/client.js:11:46237)\n    at async e.run (/var/task/node_modules/@prisma/client/runtime/client.js:11:43287)\n    at async e.execute (/var/task/node_modules/@prisma/client/runtime/client.js:57:815)\n    at async jt.request (/var/task/node_modules/@prisma/client/runtime/client.js:58:2327)\ncaused by: ",
        "name": "DriverAdapterError",
        "clientVersion": "7.5.0"
    },
    "path": "/api/inventories",
    "method": "GET",
    "msg": "Request failed"
}
```
