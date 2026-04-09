import cron from 'node-cron';

import { smartAlertService } from '../modules/alerts/smart-alert.service.js';

export const initCronJobs = () => {
  // CHẠY TỪ 8H SÁNG ĐẾN 22H ĐÊM, MỖI 2 TIẾNG 1 LẦN (8h, 10h, 12h, ..., 22h)
  // Cú pháp: 8-22/2 (Trong khoảng từ 8 đến 22, bước nhảy là 2)
  cron.schedule(
    '0 8-22/2 * * *',
    //'*/2 * * * *'
    async () => {
      console.info('🤖 [Cron] Đang chạy kiểm tra tồn kho tự động...');
      await smartAlertService.scanAllStoresForLowStock();
    },
    {
      timezone: 'Asia/Ho_Chi_Minh',
    },
  );

  console.info(
    '⏰ [Smart Cron Job] Giờ làm việc: 8h-22h, cách 2h/lần đã kích hoạt!',
  );
};
