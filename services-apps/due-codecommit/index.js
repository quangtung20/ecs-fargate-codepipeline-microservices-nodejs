const express = require('express')
const fetch = require('node-fetch');
const app = express()
const port = 3000

//https://dummyjson.com/products/1
app.get('/', (req, res) => {
  res.json({
    msg: "Hello world! (from due v1)",
  })
})
app.get('/healthcheck', (req, res) => {
  res.send('Hello World!')
})

app.get('/testing', (req, res) => {
  res.send('test testing function')
})

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
})

