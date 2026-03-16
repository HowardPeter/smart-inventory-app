import { supabase } from '../../../config/supabaseClient.js';
import { prisma } from '../../../db/prismaClient.js';

import type { RegisterDto } from '../../auth/dtos/register-email-pw.dto.js';

export const registerUser = async (dto: RegisterDto) => {
  const { email, password, fullName } = dto;

  // 1️⃣ tạo user trong Supabase Auth
  const { data, error } = await supabase.auth.admin.createUser({
    email,
    password,
    email_confirm: false,
  });

  if (error) {
    throw new Error(error.message);
  }

  const supabaseUserId = data.user.id;

  // 2️⃣ lưu user vào database
  const user = await prisma.userProfile.create({
    data: {
      auth_user_id: supabaseUserId,
      email,
      full_name: fullName,
    },
  });

  return user;
};
