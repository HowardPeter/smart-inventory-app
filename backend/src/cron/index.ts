import cron from 'node-cron';

import { smartAlertService } from '../modules/alerts/smart-alert.service.js';

export const initCronJobs = () => {
  // Chỉ thông báo vào lúc 20h mỗi ngày
  cron.schedule(
    //'*/1 * * * *', // mỗi phút 1 lần ( test )
    '0 20 * * *',
    async () => {
      console.info('[Cron] Đang chạy kiểm tra tồn kho tự động...');
      await smartAlertService.scanAllStoresForLowStock();
    },
    {
      timezone: 'Asia/Ho_Chi_Minh',
    },
  );

  console.info('[Smart Cron Job] Nhắc nhở hàng tồn kho vào mỗi 20h hằng ngày!');
};
