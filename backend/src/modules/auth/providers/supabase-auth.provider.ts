import {
  createClient,
  type SupabaseClient,
  type User,
} from '@supabase/supabase-js';
import { StatusCodes } from 'http-status-codes';

import { CustomError } from '../../../common/errors/index.js';

type VerifyAccessTokenResult = {
  user: User;
};

class SupabaseAuthProvider {
  private readonly client: SupabaseClient;

  public constructor() {
    const supabaseUrl = process.env.SUPABASE_URL;
    const supabaseAnonKey = process.env.SUPABASE_ANON_KEY;

    if (!supabaseUrl || !supabaseAnonKey) {
      throw new CustomError({
        message:
          'Missing SUPABASE_URL or SUPABASE_ANON_KEY environment variable.',
        status: StatusCodes.UNAUTHORIZED,
      });
    }

    this.client = createClient(supabaseUrl, supabaseAnonKey, {
      auth: {
        persistSession: false,
        autoRefreshToken: false,
      },
    });
  }

  public async verifyAccessToken(
    accessToken: string,
  ): Promise<VerifyAccessTokenResult> {
    const { data, error } = await this.client.auth.getUser(accessToken);

    if (error || !data.user) {
      throw new CustomError({
        message: 'Invalid or expired access token',
        status: StatusCodes.FORBIDDEN
      });
    }

    return {
      user: data.user,
    };
  }
}

export const supabaseAuthProvider = new SupabaseAuthProvider();
