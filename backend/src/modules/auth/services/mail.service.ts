import nodemailer from 'nodemailer';

if (!process.env.EMAIL_USER || !process.env.EMAIL_PASS) {
  throw new Error('Email service not configured');
}

const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});

export const sendVerifyEmail = async (email: string, verifyLink: string) => {
  try {
    await transporter.sendMail({
      from: process.env.EMAIL_USER,
      to: email,
      subject: 'Verify your email',
      html: `
        <div style="font-family: Arial, sans-serif; padding: 20px;">
          <h2>Verify your email</h2>
          <p>Click the button below to verify your account:</p>
          <a href="${verifyLink}" 
             style="padding:10px 20px;background:#4CAF50;color:white;text-decoration:none;border-radius:5px;">
            Verify Email
          </a>
        </div>
      `,
    });
  } catch (error) {
    console.error('SEND MAIL ERROR:', error);
    throw new Error('Failed to send verification email');
  }
};
