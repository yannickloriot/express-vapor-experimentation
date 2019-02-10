const bodyParser = require('body-parser');
const express = require('express');
const exphbs  = require('express-handlebars');
const redis = require("redis");

const port = 3000;

const app = express();

app.use(bodyParser.urlencoded({ extended: true }));
app.engine('handlebars', exphbs({}));
app.set('view engine', 'handlebars');

const client = redis.createClient({ host: process.env.REDIS_HOSTNAME });
client.on('error', function (err) {
    console.log(`Error ${err}`);
});

app.get('/', (req, res) => {
    client.smembers('items', (err, items) => {
        if (err) return res.status(500).send({ error: err });

        res.render('home', { items });
    })
});

app.post('/', (req, res) => {
    client.sadd('items', req.body.title, err => {
        if (err) return res.status(500).send({ error: err });

        res.redirect('/');
    });
});

app.get('/delete/:itemId', (req, res) => {
    client.srem('items', req.params.itemId, err => {
        if (err) return res.status(500).send({ error: err });

        res.redirect('/');
    });
});

app.listen(port, () => console.log(`Example app listening on port ${port}!`));