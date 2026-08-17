const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

app.get('/', (req, res) => {
    res.send(`
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <title>Express HTML Demo</title>
            <style>
                body { background-color: #e3d9d9; font-family: sans-serif; text-align: center; margin-top: 50px; }
                h1 { color: #333; }
                h2 { color: #030a04; }
                p { color: #330303; }
            </style>
        </head>
        <body>
            <h1>Hello from ....... Vande Bharat!</h1>
            <h2>Welcome to the Indian Railway</h2>
            <p>This web application is deployed using Kubernetes and Argocd</p>
        </body>
        </html>
    `);
});

app.get('/health', (req, res) => {
    res.status(200).send('OK');
});

app.get('/about', (req, res) => {
    res.json({
        name: "gitops-nodejs-app",
        version: "1.0.0",
        description: "Node.js app deployed with GitHub Actions and ArgoCD",
        deployment: "Kubernetes with ArgoCD"
    });
});

app.listen(port, () => {
  console.log(`App running on http://localhost:${port}`);
});