import { SmartDecisionController } from './controllers/smart-decision.controller.js';
import { SmartDecisionService } from './smart-decision.service.js';

// 1. Khởi tạo Service
const smartDecisionService = new SmartDecisionService();

// 2. Khởi tạo Controller và Inject Service vào
const smartDecisionController = new SmartDecisionController(
  smartDecisionService,
);

// 3. Export để Route và file Cron Job sử dụng
export { smartDecisionService, smartDecisionController };
