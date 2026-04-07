/* Hàm hỗ trợ auditLog detect log update
chỉ lấy các trường có thay đổi và lưu vào oldValue, newValue */
export const buildAuditDiff = <T extends Record<string, unknown>>(
  oldData: T,
  newData: Partial<T>,
): { oldValue: Record<string, unknown>; newValue: Record<string, unknown> } => {
  const oldValue: Record<string, unknown> = {};
  const newValue: Record<string, unknown> = {};

  for (const key in newData) {
    const newVal = newData[key];
    const oldVal = oldData[key];

    // bỏ qua undefined (field không được gửi lên)
    if (newVal === undefined) {
      continue;
    }

    // chỉ log khi có thay đổi
    if (newVal !== oldVal) {
      oldValue[key] = oldVal ?? null;
      newValue[key] = newVal;
    }
  }

  return { oldValue, newValue };
};
