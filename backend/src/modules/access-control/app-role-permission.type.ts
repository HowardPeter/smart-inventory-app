import type { ROLE, PERMISSION } from './role-permission.constant.js';

export type AppRole = (typeof ROLE)[keyof typeof ROLE];
export type AppPermission = (typeof PERMISSION)[keyof typeof PERMISSION];
