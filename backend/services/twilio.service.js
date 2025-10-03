const twilio = require('twilio');

class TwilioService {
  constructor() {
    if (process.env.TWILIO_ACCOUNT_SID && process.env.TWILIO_AUTH_TOKEN) {
      this.client = twilio(
        process.env.TWILIO_ACCOUNT_SID,
        process.env.TWILIO_AUTH_TOKEN
      );
      this.phoneNumber = process.env.TWILIO_PHONE_NUMBER;
      this.enabled = true;
    } else {
      this.enabled = false;
      console.warn('⚠️ Twilio credentials not configured. SMS will be logged instead.');
    }
  }

  async sendSMS(to, message) {
    try {
      if (!this.enabled) {
        console.log(`📱 SMS to ${to}: ${message}`);
        return { sid: 'mock_' + Date.now(), status: 'sent' };
      }

      const result = await this.client.messages.create({
        body: message,
        from: this.phoneNumber,
        to: to
      });

      console.log(`✅ SMS sent to ${to}: ${result.sid}`);
      return result;
    } catch (error) {
      console.error('❌ Failed to send SMS:', error);
      throw error;
    }
  }

  async sendOTP(phoneNumber, otp) {
    const message = `Your Super App verification code is: ${otp}\n\nThis code will expire in 10 minutes.`;
    return await this.sendSMS(phoneNumber, message);
  }

  async sendNotification(phoneNumber, notification) {
    const message = `Super App Notification:\n${notification}`;
    return await this.sendSMS(phoneNumber, message);
  }

  async makeCall(to, twimlUrl) {
    try {
      if (!this.enabled) {
        console.log(`📞 Call to ${to} with URL: ${twimlUrl}`);
        return { sid: 'mock_call_' + Date.now(), status: 'initiated' };
      }

      const call = await this.client.calls.create({
        url: twimlUrl,
        to: to,
        from: this.phoneNumber
      });

      console.log(`✅ Call initiated to ${to}: ${call.sid}`);
      return call;
    } catch (error) {
      console.error('❌ Failed to make call:', error);
      throw error;
    }
  }

  async verifyPhoneNumber(phoneNumber) {
    try {
      if (!this.enabled) {
        console.log(`✅ Phone number verified (mock): ${phoneNumber}`);
        return { valid: true, phoneNumber };
      }

      const lookup = await this.client.lookups.v1
        .phoneNumbers(phoneNumber)
        .fetch();

      return {
        valid: true,
        phoneNumber: lookup.phoneNumber,
        countryCode: lookup.countryCode,
        nationalFormat: lookup.nationalFormat
      };
    } catch (error) {
      if (error.status === 404) {
        return { valid: false, phoneNumber };
      }
      throw error;
    }
  }

  async sendWhatsApp(to, message) {
    try {
      if (!this.enabled) {
        console.log(`💬 WhatsApp to ${to}: ${message}`);
        return { sid: 'mock_whatsapp_' + Date.now(), status: 'sent' };
      }

      const result = await this.client.messages.create({
        body: message,
        from: `whatsapp:${this.phoneNumber}`,
        to: `whatsapp:${to}`
      });

      console.log(`✅ WhatsApp message sent to ${to}: ${result.sid}`);
      return result;
    } catch (error) {
      console.error('❌ Failed to send WhatsApp message:', error);
      throw error;
    }
  }

  async sendBulkSMS(recipients, message) {
    const results = [];
    
    for (const recipient of recipients) {
      try {
        const result = await this.sendSMS(recipient, message);
        results.push({ recipient, success: true, sid: result.sid });
      } catch (error) {
        results.push({ recipient, success: false, error: error.message });
      }
    }

    return results;
  }
}

module.exports = new TwilioService();