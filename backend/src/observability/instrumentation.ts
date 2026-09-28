import { registerInstrumentations } from '@opentelemetry/instrumentation';
import { ExpressInstrumentation } from '@opentelemetry/instrumentation-express';
import { PrismaInstrumentation } from '@prisma/instrumentation';

registerInstrumentations({
  instrumentations: [new ExpressInstrumentation(), new PrismaInstrumentation()],
});
