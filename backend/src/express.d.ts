import type { CurrentUser, StoreContext } from './common/types/index.ts';

/* chỉ định thêm user và storeContext trong Request express (req) với type là:
    user: CurrentUser | undefined
    storeContext: StoreContext | undefined
 */
declare global {
  namespace Express {
    interface Request {
      user?: CurrentUser;
      storeContext?: StoreContext;
    }
  }
}

export {};
