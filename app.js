const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

// Home route
app.get('/', (req, res) => {
  res.json({
    message: '🚀 CI/CD Pipeline Demo - App is Running!',
    version: '1.0.0',
    status: 'healthy',
    environment: process.env.NODE_ENV || 'development',
    timestamp: new Date().toISOString(),
    deployedBy: 'Jenkins + Docker'
  });
});

// Health check route (used by Docker/Jenkins to verify app is up)
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'UP', uptime: process.uptime() });
});

// Info route
app.get('/info', (req, res) => {
  res.json({
    app: 'cicd-demo',
    author: 'DevOps Demo',
    pipeline: ['GitHub Push', 'Jenkins Trigger', 'Docker Build', 'Container Deploy'],
    tools: ['Node.js', 'Express', 'Docker', 'Jenkins', 'GitHub']
  });
});

app.listen(PORT, '0.0.0.0',() => {
  console.log(`✅ Server running on port ${PORT}`);
  console.log(`🌍 http://localhost:${PORT}`);
});

module.exports = app;
