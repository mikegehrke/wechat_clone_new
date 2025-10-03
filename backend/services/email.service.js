const nodemailer = require('nodemailer');

class EmailService {
  constructor() {
    if (process.env.EMAIL_HOST && process.env.EMAIL_USER && process.env.EMAIL_PASSWORD) {
      this.transporter = nodemailer.createTransporter({
        host: process.env.EMAIL_HOST,
        port: process.env.EMAIL_PORT || 587,
        secure: false,
        auth: {
          user: process.env.EMAIL_USER,
          pass: process.env.EMAIL_PASSWORD
        }
      });
      this.enabled = true;
    } else {
      this.enabled = false;
      console.warn('⚠️ Email credentials not configured. Emails will be logged instead.');
    }

    this.fromEmail = process.env.EMAIL_USER || 'noreply@superapp.com';
    this.appName = 'Super App';
  }

  async sendEmail({ to, subject, html, text }) {
    try {
      if (!this.enabled) {
        console.log(`📧 Email to ${to}:`);
        console.log(`Subject: ${subject}`);
        console.log(`Content: ${text || html}`);
        return { messageId: 'mock_' + Date.now() };
      }

      const mailOptions = {
        from: `${this.appName} <${this.fromEmail}>`,
        to,
        subject,
        text,
        html
      };

      const info = await this.transporter.sendMail(mailOptions);
      console.log(`✅ Email sent to ${to}: ${info.messageId}`);
      return info;
    } catch (error) {
      console.error('❌ Failed to send email:', error);
      throw error;
    }
  }

  async sendWelcomeEmail(email, userName) {
    const subject = `Welcome to ${this.appName}!`;
    const html = `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h1 style="color: #333;">Welcome to ${this.appName}, ${userName}!</h1>
        <p style="color: #666; font-size: 16px;">
          We're excited to have you on board. Your account has been successfully created.
        </p>
        <p style="color: #666; font-size: 16px;">
          Here are some things you can do to get started:
        </p>
        <ul style="color: #666; font-size: 16px;">
          <li>Complete your profile</li>
          <li>Connect with friends</li>
          <li>Explore our features</li>
        </ul>
        <div style="margin-top: 30px; padding: 20px; background-color: #f5f5f5; border-radius: 5px;">
          <p style="color: #999; font-size: 14px; margin: 0;">
            If you have any questions, feel free to reach out to our support team.
          </p>
        </div>
      </div>
    `;

    return await this.sendEmail({
      to: email,
      subject,
      html,
      text: `Welcome to ${this.appName}, ${userName}! We're excited to have you on board.`
    });
  }

  async sendPasswordResetEmail(email, resetUrl) {
    const subject = 'Reset Your Password';
    const html = `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h1 style="color: #333;">Password Reset Request</h1>
        <p style="color: #666; font-size: 16px;">
          We received a request to reset your password. Click the button below to reset it.
        </p>
        <div style="text-align: center; margin: 30px 0;">
          <a href="${resetUrl}" 
             style="background-color: #007bff; color: white; padding: 12px 30px; 
                    text-decoration: none; border-radius: 5px; display: inline-block;">
            Reset Password
          </a>
        </div>
        <p style="color: #666; font-size: 14px;">
          Or copy and paste this link into your browser:
        </p>
        <p style="color: #007bff; font-size: 14px; word-break: break-all;">
          ${resetUrl}
        </p>
        <p style="color: #999; font-size: 14px; margin-top: 30px;">
          This link will expire in 1 hour. If you didn't request this, please ignore this email.
        </p>
      </div>
    `;

    return await this.sendEmail({
      to: email,
      subject,
      html,
      text: `Reset your password by visiting: ${resetUrl}`
    });
  }

  async sendVerificationEmail(email, verificationUrl) {
    const subject = 'Verify Your Email Address';
    const html = `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h1 style="color: #333;">Verify Your Email</h1>
        <p style="color: #666; font-size: 16px;">
          Please verify your email address to complete your registration.
        </p>
        <div style="text-align: center; margin: 30px 0;">
          <a href="${verificationUrl}" 
             style="background-color: #28a745; color: white; padding: 12px 30px; 
                    text-decoration: none; border-radius: 5px; display: inline-block;">
            Verify Email
          </a>
        </div>
        <p style="color: #666; font-size: 14px;">
          Or copy and paste this link into your browser:
        </p>
        <p style="color: #007bff; font-size: 14px; word-break: break-all;">
          ${verificationUrl}
        </p>
        <p style="color: #999; font-size: 14px; margin-top: 30px;">
          This link will expire in 24 hours.
        </p>
      </div>
    `;

    return await this.sendEmail({
      to: email,
      subject,
      html,
      text: `Verify your email by visiting: ${verificationUrl}`
    });
  }

  async sendOTPEmail(email, otp) {
    const subject = 'Your Verification Code';
    const html = `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h1 style="color: #333;">Verification Code</h1>
        <p style="color: #666; font-size: 16px;">
          Your verification code is:
        </p>
        <div style="text-align: center; margin: 30px 0;">
          <div style="background-color: #f5f5f5; padding: 20px; border-radius: 5px; 
                      display: inline-block;">
            <h2 style="color: #007bff; font-size: 32px; margin: 0; letter-spacing: 5px;">
              ${otp}
            </h2>
          </div>
        </div>
        <p style="color: #999; font-size: 14px;">
          This code will expire in 10 minutes. Do not share this code with anyone.
        </p>
      </div>
    `;

    return await this.sendEmail({
      to: email,
      subject,
      html,
      text: `Your verification code is: ${otp}. This code will expire in 10 minutes.`
    });
  }

  async sendPaymentReceiptEmail(email, transaction) {
    const subject = 'Payment Receipt';
    const html = `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h1 style="color: #333;">Payment Receipt</h1>
        <div style="background-color: #f5f5f5; padding: 20px; border-radius: 5px; margin: 20px 0;">
          <p style="color: #666; font-size: 16px; margin: 5px 0;">
            <strong>Transaction ID:</strong> ${transaction.id}
          </p>
          <p style="color: #666; font-size: 16px; margin: 5px 0;">
            <strong>Amount:</strong> $${transaction.amount.toFixed(2)}
          </p>
          <p style="color: #666; font-size: 16px; margin: 5px 0;">
            <strong>Date:</strong> ${new Date(transaction.createdAt).toLocaleString()}
          </p>
          <p style="color: #666; font-size: 16px; margin: 5px 0;">
            <strong>Description:</strong> ${transaction.description}
          </p>
        </div>
        <p style="color: #999; font-size: 14px;">
          Thank you for your payment. If you have any questions, please contact support.
        </p>
      </div>
    `;

    return await this.sendEmail({
      to: email,
      subject,
      html,
      text: `Payment Receipt - Transaction ID: ${transaction.id}, Amount: $${transaction.amount.toFixed(2)}`
    });
  }

  async sendOrderConfirmationEmail(email, order) {
    const subject = 'Order Confirmation';
    const html = `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h1 style="color: #333;">Order Confirmation</h1>
        <p style="color: #666; font-size: 16px;">
          Thank you for your order! Your order has been confirmed.
        </p>
        <div style="background-color: #f5f5f5; padding: 20px; border-radius: 5px; margin: 20px 0;">
          <p style="color: #666; font-size: 16px; margin: 5px 0;">
            <strong>Order ID:</strong> ${order.id}
          </p>
          <p style="color: #666; font-size: 16px; margin: 5px 0;">
            <strong>Total:</strong> $${order.total.toFixed(2)}
          </p>
          <p style="color: #666; font-size: 16px; margin: 5px 0;">
            <strong>Estimated Delivery:</strong> ${order.estimatedDelivery}
          </p>
        </div>
        <h3 style="color: #333;">Order Items:</h3>
        <ul style="color: #666; font-size: 16px;">
          ${order.items.map(item => `
            <li>${item.name} x ${item.quantity} - $${(item.price * item.quantity).toFixed(2)}</li>
          `).join('')}
        </ul>
        <p style="color: #999; font-size: 14px; margin-top: 30px;">
          You can track your order status in the app.
        </p>
      </div>
    `;

    return await this.sendEmail({
      to: email,
      subject,
      html,
      text: `Order Confirmation - Order ID: ${order.id}, Total: $${order.total.toFixed(2)}`
    });
  }

  async sendBulkEmail(recipients, subject, content) {
    const results = [];
    
    for (const recipient of recipients) {
      try {
        const result = await this.sendEmail({
          to: recipient,
          subject,
          html: content.html,
          text: content.text
        });
        results.push({ recipient, success: true, messageId: result.messageId });
      } catch (error) {
        results.push({ recipient, success: false, error: error.message });
      }
    }

    return results;
  }
}

module.exports = new EmailService();