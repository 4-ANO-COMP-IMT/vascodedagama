const express = require('express');
const axios = require('axios');
const bodyParser = require('body-parser');

const app = express();
app.use(bodyParser.json());

const events = [];

app.post('/events', (req, res) => {
  const event = req.body;

  events.push(event);

  // Encaminhar o evento para o serviço apropriado
  axios.post('http://localhost:3001/events', event).catch((err) => {
    console.log('Erro encaminhando o evento para o serviço apropriado', err.message);
  });
  axios.post('http://localhost:3002/events', event).catch((err) => {
    console.log('Erro encaminhando o evento para o serviço apropriado', err.message);
  });

  res.send({ status: 'OK' });
});

app.get('/events', (req, res) => {
  res.send(events);
});

const PORT = process.env.PORT || 3003;
app.listen(PORT, () => {
  console.log(`Buser de Eventos rodando na porta: ${PORT}`);
});
