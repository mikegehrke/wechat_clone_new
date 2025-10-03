const redis = require('redis');

class RedisClient {
  constructor() {
    this.client = null;
    this.connected = false;
    this.connect();
  }

  connect() {
    try {
      // Create Redis client
      this.client = redis.createClient({
        url: process.env.REDIS_URL || 'redis://localhost:6379',
        socket: {
          reconnectStrategy: (retries) => {
            if (retries > 10) {
              console.error('❌ Redis: Max reconnection attempts reached');
              return new Error('Max reconnection attempts reached');
            }
            return retries * 100;
          }
        }
      });

      // Event handlers
      this.client.on('connect', () => {
        console.log('✅ Redis connected');
        this.connected = true;
      });

      this.client.on('error', (err) => {
        console.error('❌ Redis error:', err);
        this.connected = false;
      });

      this.client.on('ready', () => {
        console.log('✅ Redis ready');
        this.connected = true;
      });

      // Connect
      this.client.connect().catch(err => {
        console.error('❌ Redis connection failed:', err);
        this.connected = false;
      });
    } catch (error) {
      console.error('❌ Redis initialization failed:', error);
      this.connected = false;
    }
  }

  // Wrapper methods with fallback for when Redis is not available
  async get(key) {
    try {
      if (!this.connected) return null;
      return await this.client.get(key);
    } catch (error) {
      console.error('Redis get error:', error);
      return null;
    }
  }

  async set(key, value, options) {
    try {
      if (!this.connected) return false;
      await this.client.set(key, value, options);
      return true;
    } catch (error) {
      console.error('Redis set error:', error);
      return false;
    }
  }

  async setex(key, seconds, value) {
    try {
      if (!this.connected) return false;
      await this.client.setEx(key, seconds, value);
      return true;
    } catch (error) {
      console.error('Redis setex error:', error);
      return false;
    }
  }

  async del(key) {
    try {
      if (!this.connected) return false;
      await this.client.del(key);
      return true;
    } catch (error) {
      console.error('Redis del error:', error);
      return false;
    }
  }

  async exists(key) {
    try {
      if (!this.connected) return false;
      const result = await this.client.exists(key);
      return result === 1;
    } catch (error) {
      console.error('Redis exists error:', error);
      return false;
    }
  }

  async expire(key, seconds) {
    try {
      if (!this.connected) return false;
      await this.client.expire(key, seconds);
      return true;
    } catch (error) {
      console.error('Redis expire error:', error);
      return false;
    }
  }

  async ttl(key) {
    try {
      if (!this.connected) return -1;
      return await this.client.ttl(key);
    } catch (error) {
      console.error('Redis ttl error:', error);
      return -1;
    }
  }

  // Hash operations
  async hset(key, field, value) {
    try {
      if (!this.connected) return false;
      await this.client.hSet(key, field, value);
      return true;
    } catch (error) {
      console.error('Redis hset error:', error);
      return false;
    }
  }

  async hget(key, field) {
    try {
      if (!this.connected) return null;
      return await this.client.hGet(key, field);
    } catch (error) {
      console.error('Redis hget error:', error);
      return null;
    }
  }

  async hgetall(key) {
    try {
      if (!this.connected) return {};
      return await this.client.hGetAll(key);
    } catch (error) {
      console.error('Redis hgetall error:', error);
      return {};
    }
  }

  async hdel(key, field) {
    try {
      if (!this.connected) return false;
      await this.client.hDel(key, field);
      return true;
    } catch (error) {
      console.error('Redis hdel error:', error);
      return false;
    }
  }

  // List operations
  async lpush(key, value) {
    try {
      if (!this.connected) return false;
      await this.client.lPush(key, value);
      return true;
    } catch (error) {
      console.error('Redis lpush error:', error);
      return false;
    }
  }

  async rpush(key, value) {
    try {
      if (!this.connected) return false;
      await this.client.rPush(key, value);
      return true;
    } catch (error) {
      console.error('Redis rpush error:', error);
      return false;
    }
  }

  async lrange(key, start, stop) {
    try {
      if (!this.connected) return [];
      return await this.client.lRange(key, start, stop);
    } catch (error) {
      console.error('Redis lrange error:', error);
      return [];
    }
  }

  async llen(key) {
    try {
      if (!this.connected) return 0;
      return await this.client.lLen(key);
    } catch (error) {
      console.error('Redis llen error:', error);
      return 0;
    }
  }

  // Set operations
  async sadd(key, member) {
    try {
      if (!this.connected) return false;
      await this.client.sAdd(key, member);
      return true;
    } catch (error) {
      console.error('Redis sadd error:', error);
      return false;
    }
  }

  async srem(key, member) {
    try {
      if (!this.connected) return false;
      await this.client.sRem(key, member);
      return true;
    } catch (error) {
      console.error('Redis srem error:', error);
      return false;
    }
  }

  async smembers(key) {
    try {
      if (!this.connected) return [];
      return await this.client.sMembers(key);
    } catch (error) {
      console.error('Redis smembers error:', error);
      return [];
    }
  }

  async sismember(key, member) {
    try {
      if (!this.connected) return false;
      const result = await this.client.sIsMember(key, member);
      return result === 1;
    } catch (error) {
      console.error('Redis sismember error:', error);
      return false;
    }
  }

  // Pub/Sub operations
  async publish(channel, message) {
    try {
      if (!this.connected) return false;
      await this.client.publish(channel, message);
      return true;
    } catch (error) {
      console.error('Redis publish error:', error);
      return false;
    }
  }

  async subscribe(channel, callback) {
    try {
      if (!this.connected) return false;
      
      const subscriber = this.client.duplicate();
      await subscriber.connect();
      
      await subscriber.subscribe(channel, (message) => {
        callback(message);
      });
      
      return subscriber;
    } catch (error) {
      console.error('Redis subscribe error:', error);
      return null;
    }
  }

  // Cache helper methods
  async cache(key, ttl, fetchFunction) {
    try {
      // Try to get from cache
      const cached = await this.get(key);
      if (cached) {
        return JSON.parse(cached);
      }

      // Fetch fresh data
      const data = await fetchFunction();
      
      // Store in cache
      await this.setex(key, ttl, JSON.stringify(data));
      
      return data;
    } catch (error) {
      console.error('Cache error:', error);
      // Return fresh data even if caching fails
      return await fetchFunction();
    }
  }

  async invalidate(pattern) {
    try {
      if (!this.connected) return false;
      
      const keys = await this.client.keys(pattern);
      if (keys.length > 0) {
        await this.client.del(keys);
      }
      
      return true;
    } catch (error) {
      console.error('Redis invalidate error:', error);
      return false;
    }
  }

  // Session management
  async setSession(sessionId, userData, ttl = 86400) {
    return await this.setex(`session:${sessionId}`, ttl, JSON.stringify(userData));
  }

  async getSession(sessionId) {
    const data = await this.get(`session:${sessionId}`);
    return data ? JSON.parse(data) : null;
  }

  async deleteSession(sessionId) {
    return await this.del(`session:${sessionId}`);
  }

  // Rate limiting
  async checkRateLimit(key, limit, window) {
    try {
      if (!this.connected) return { allowed: true, remaining: limit };
      
      const current = await this.client.incr(key);
      
      if (current === 1) {
        await this.expire(key, window);
      }
      
      const ttl = await this.ttl(key);
      
      return {
        allowed: current <= limit,
        remaining: Math.max(0, limit - current),
        resetIn: ttl
      };
    } catch (error) {
      console.error('Rate limit check error:', error);
      return { allowed: true, remaining: limit };
    }
  }

  // Clean up
  async disconnect() {
    try {
      if (this.client) {
        await this.client.quit();
        this.connected = false;
        console.log('Redis disconnected');
      }
    } catch (error) {
      console.error('Redis disconnect error:', error);
    }
  }
}

// Create singleton instance
const redisClient = new RedisClient();

module.exports = redisClient;