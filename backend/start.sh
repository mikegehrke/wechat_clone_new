#!/bin/bash

echo "🚀 Starting Super App Backend..."

# Check if .env file exists
if [ ! -f .env ]; then
    echo "📝 Creating .env file from .env.example..."
    cp .env.example .env
    echo "⚠️  Please update .env file with your credentials"
fi

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install
fi

# Check if MongoDB is running
if ! nc -z localhost 27017 2>/dev/null; then
    echo "⚠️  MongoDB is not running. Starting with Docker..."
    docker-compose up -d mongodb redis
    echo "⏳ Waiting for MongoDB to start..."
    sleep 5
fi

# Check if Redis is running
if ! nc -z localhost 6379 2>/dev/null; then
    echo "⚠️  Redis is not running. Starting with Docker..."
    docker-compose up -d redis
    echo "⏳ Waiting for Redis to start..."
    sleep 3
fi

# Start the server
echo "✅ Starting server in development mode..."
npm run dev