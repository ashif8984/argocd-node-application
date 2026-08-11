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
                body { background-color: #c2f576; font-family: sans-serif; text-align: center; margin-top: 50px; }
                h1 { color: #333; }
                p { color: #666; }
            </style>
        </head>
        <body>
            <h1>Hello from Express!</h1>
            <p>This page is rendered directly using HTML tags inside Express.</p>
        </body>
        </html>
    `);
});
app.listen(port, () => {
  console.log(`App running on http://localhost:${port}`);
});