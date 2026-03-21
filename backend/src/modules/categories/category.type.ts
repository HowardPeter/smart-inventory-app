export type Category = {
  categoryId: string;
  name: string;
  description: string | null;
  isDefault: boolean;
  storeId: string | null;
};

export type HidedDefault = {
  storeId: string;
  categoryId: string;
};
