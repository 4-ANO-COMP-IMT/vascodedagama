const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const axios = require('axios');  // Importando o Axios para enviar eventos para o Buser de Eventos

const app = express();
app.use(cors());
app.use(bodyParser.json());

let players = [
  {
    id: 1,
    name: 'Jogador 1',
    height: '180cm',
    team: 'Time A',
    price: '10M',
    foot: 'Direito',
    position: 'Atacante',
    league: 'Premier League',
    icon: 'player1.png'
  },
  // Adiciona mais jogadores caso necessario (futuramente usar banco de dados)
];

// Get em todos os jogadores
app.get('/players', (req, res) => {
  res.status(200).send(players);
});

// Get em jogador por id
app.get('/players/:id', (req, res) => {
  const player = players.find(p => p.id === parseInt(req.params.id, 10));
  if (player) {
    res.status(200).send(player);
  } else {
    res.status(404).send({ error: 'Jogador Faltando' });
  }
});

// Adiciona um novo jogador
app.post('/players', (req, res) => {
  const newPlayer = {
    id: players.length + 1, // Incrementando o id
    ...req.body
  };
  players.push(newPlayer);
  res.status(201).send(newPlayer);
});

app.post('/events', (req, res) => {
  console.log('Evento recebido:', req.body.type);
  res.send({});
});

const PORT = process.env.PORT || 3002;
app.listen(PORT, () => {
  console.log(`Serviço de jogador rodando na porta: ${PORT}`);
});
