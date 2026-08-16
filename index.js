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
                body { background-color: #c23838; font-family: sans-serif; text-align: center; margin-top: 50px; }
                h1 { color: #333; }
                h2 { color: #030a04; }
                p { color: #330303; }
            </style>
        </head>
        <body>
            <h1>Hello from Vande Bharat!</h1>
            <h2>Welcome to the Express HTML Demo</h2>
            <p>This web application is deployed using Kubernetes and Argocd</p>
        </body>
        </html>
    `);
});
app.listen(port, () => {
  console.log(`App running on http://localhost:${port}`);
});