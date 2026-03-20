import { StatusCodes } from 'http-status-codes';

import { CustomError } from '../../../common/errors/index.js';
import { userFacade } from '../../user/user.module.js';
import { AUTH_HEADER, BEARER_PREFIX } from '../constants/auth.constant.js';
import { supabaseAuthProvider } from '../providers/supabase-auth.provider.js';

import type { CurrentUser } from '../../../common/types/index.js';
import type { Request } from 'express';

class AuthSessionService {
  public extractAccessToken(req: Request): string {
    const authorizationHeader = req.header(AUTH_HEADER);

    if (!authorizationHeader) {
      throw new CustomError({
        message: 'Missing Authorization header.',
        status: StatusCodes.UNAUTHORIZED,
      });
    }

    if (!authorizationHeader.startsWith(BEARER_PREFIX)) {
      throw new CustomError({
        message: 'Authorization header must use Bearer token.',
        status: StatusCodes.UNAUTHORIZED,
      });
    }

    const accessToken = authorizationHeader.slice(BEARER_PREFIX.length).trim();

    if (!accessToken) {
      throw new CustomError({
        message: 'Access token is empty.',
        status: StatusCodes.UNAUTHORIZED,
      });
    }

    return accessToken;
  }

  public async authenticateRequest(req: Request): Promise<CurrentUser> {
    const accessToken = this.extractAccessToken(req);

    const { user: supabaseUser } =
      await supabaseAuthProvider.verifyAccessToken(accessToken);

    const authUserId = supabaseUser.id;
    const email = supabaseUser.email;

    if (!email) {
      throw new CustomError({
        message: 'Authenticated user does not have email.',
        status: StatusCodes.UNAUTHORIZED,
      });
    }

    const userProfile = await userFacade.getActiveUserByAuthUserId(authUserId);

    if (!userProfile) {
      throw new CustomError({
        message: 'User profile not found or inactive.',
        status: StatusCodes.UNAUTHORIZED,
      });
    }

    return {
      userId: userProfile.userId,
      authUserId: authUserId,
      email: userProfile.email,
    };
  }

  public async verifyOnlyToken(req: Request) {
    const accessToken = this.extractAccessToken(req);
    const { user: supabaseUser } =
      await supabaseAuthProvider.verifyAccessToken(accessToken);

    return {
      authUserId: supabaseUser.id,
      email: supabaseUser.email,
    };
  }
}

export const authSessionService = new AuthSessionService();
