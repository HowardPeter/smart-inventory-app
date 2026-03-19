// import { sendVerifyEmail } from './mail.service.js';
// import { SupabaseProvider } from '../../../config/supabaseClient.js';
// import { prisma } from '../../../db/prismaClient.js';

// import type { RegisterDto } from '../../auth/dtos/register-email-pw.dto.js';

// export const registerUserService = async (dto: RegisterDto) => {
//   const { email, password, fullName } = dto;

//   const normalizedEmail = email.toLowerCase().trim();

//   let supabaseUserId: string | null = null;
//   const supabase = SupabaseProvider.getClient();

//   try {
//     const { data, error } = await supabase.auth.admin.createUser({
//       email: normalizedEmail,
//       password,
//       email_confirm: false,
//     });

//     if (error) {
//       if (error.message.includes('already')) {
//         throw new Error('Email already registered');
//       }
//       throw new Error(error.message);
//     }

//     supabaseUserId = data.user.id;

//     const { data: linkData, error: linkError } =
//       await supabase.auth.admin.generateLink({
//         type: 'invite',
//         email: normalizedEmail,
//         options: {
//           redirectTo: 'http://127.0.0.1:3000/auth/callback',
//         },
//       });

//     if (linkError) {
//       throw new Error(linkError.message);
//     }

//     const verifyLink = linkData?.properties?.action_link;

//     if (!verifyLink) {
//       throw new Error('Failed to generate verify link');
//     }

//     await sendVerifyEmail(normalizedEmail, verifyLink);

//     const profile = await prisma.userProfile.create({
//       data: {
//         authUserId: supabaseUserId,
//         email: email,
//         fullName: fullName.trim(),
//         activeStatus: 'active',
//       },
//     });

//     return profile;
//   } catch (error) {
//     console.error('REGISTER ERROR:', error);

//     if (supabaseUserId) {
//       await supabase.auth.admin.deleteUser(supabaseUserId);
//     }

//     throw error;
//   }
// };
