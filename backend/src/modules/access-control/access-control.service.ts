import { ROLE_PERMISSIONS } from './role-permission.map.js';

import type { AppRole, AppPermission } from './app-role-permission.type.js';

class AccessControlService {
  public getPermissionsByRole(role: AppRole): AppPermission[] {
    return ROLE_PERMISSIONS[role] ?? [];
  }

  public hasPermission(params: {
    role: AppRole;
    permission: AppPermission;
  }): boolean {
    const { role, permission } = params;

    const permissions = this.getPermissionsByRole(role);

    return permissions.includes(permission);
  }
}

export const accessControlService = new AccessControlService();
