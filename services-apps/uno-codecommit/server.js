const express = require('express')
const fetch = require('node-fetch')

const sequelize = require('sequelize');

const app = express()
const port = 3000
let count = 0

const dbName = (process.env.DB_NAME != undefined) ? `${process.env.DB_NAME}` : 'sakila';
const dbUserName = (process.env.DB_USERNAME != undefined) ? `${process.env.DB_USERNAME}` : 'root';
const dbPassword = (process.env.DB_PASS != undefined) ? `${process.env.DB_PASS}` : '123456789';
const dbHost = (process.env.DB_HOST != undefined) ? `${process.env.DB_HOST}` : 'terraform-20231206033123072700000001.csmdudwzhwjp.us-east-1.rds.amazonaws.com';

const db = new sequelize(dbName, dbUserName, dbPassword, {
    host: dbHost,
    port: 3306,
    dialect: 'mysql'
});

db.authenticate()
    .then(() => {
        console.log('connect success');
        console.log({
            dbName,
            dbUserName,
            dbPassword,
            dbHost
        })
    })
    .catch(err => {
        console.error('connect error: ', err);
    });

//https://dummyjson.com/products/1
app.get('/', async (req, res) => {
    const dueResponse = await fetch(`${process.env.DUE_SERVICE_API_BASE}:3000`)
    const treResponse = await fetch(`${process.env.TRE_SERVICE_API_BASE}:3000`)
    const dueData = await dueResponse.json();
    const treData = await treResponse.json();
    count++;
    console.log(count);
    res.json({
        msg: "Hello world! (from uno) v1",
        due: {
            url: process.env.DUE_SERVICE_API_BASE,
            data: dueData,
        },
        uno: {
            url: process.env.TRE_SERVICE_API_BASE,
            data: treData,
        }
    })
})

app.get('/healthcheck', (req, res) => {
    res.send('Hello World!')
})

app.listen(port, () => {
    console.log(`Example app listening on port ${port}`)
})