import { SupabaseProvider } from '../../config/supabaseClient.js';

export class StorageService {
  /**
   * Tạo Signed URL cho ảnh có thời hạn truy cập (vd: 1 giờ)
   */
  static async getSignedUrl(
    bucket: string,
    path: string | null,
  ): Promise<string | null> {
    if (!path) {
      return null;
    }

    try {
      // 1. Gọi Singleton Client từ Provider của bạn
      const supabase = SupabaseProvider.getClient();

      // 2. Sử dụng client để tạo Signed URL
      const { data, error } = await supabase.storage
        .from(bucket)
        .createSignedUrl(path, 60 * 60); // 3600 giây = 1 giờ

      if (error) {
        console.error('Lỗi khi tạo signed URL Supabase:', error);

        return null;
      }

      return data.signedUrl;
    } catch (error) {
      console.error('Exception khi gọi Supabase:', error);

      return null;
    }
  }
}
