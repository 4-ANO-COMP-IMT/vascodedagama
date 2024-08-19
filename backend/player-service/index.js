const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const axios = require('axios');  // Importando o Axios para enviar eventos para o Event Bus

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
  {
    id: 2,
    name: 'Jogador 2',
    height: '177cm',
    team: 'Time B',
    price: '12M',
    foot: 'Direito',
    position: 'Atacante',
    league: 'La Liga',
    icon: 'player2.png'
  },
  {
    id: 3,
    name: 'Jogador 3',
    height: '156cm',
    team: 'Time C',
    price: '12M',
    foot: 'Esquerdo',
    position: 'Zagueiro',
    league: 'La Liga',
    icon: 'player3.png'
  },
  {
    id: 4,
    name: 'Jogador 4',
    height: '192cm',
    team: 'Time B',
    price: '14M',
    foot: 'Direito',
    position: 'Zagueiro',
    league: 'La Liga',
    icon: 'player4.png'
  },
  // Adicione mais jogadores caso necessário (futuramente usar banco de dados)
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
    res.status(404).send({ error: 'Jogador não encontrado' });
  }
});

// Adiciona um novo jogador manualmente 
app.post('/players', (req, res) => {
  const newPlayer = {
    id: players.length + 1, // Incrementando o id
    ...req.body
  };
  players.push(newPlayer);

  // Manda o Evento pro Event Bus
  axios.post('http://localhost:3003/events', {
    type: 'Novo Jogador Criado',
    data: newPlayer
  }).catch((err) => {
    console.log('Erro enviando evento para o Event Bus', err.message);
  });

  res.status(201).send(newPlayer);
});

app.post('/events', (req, res) => {
  console.log('Evento recebido:', req.body.type);
  res.send({});
});

// Endpoint para retornar um jogador secreto aleatório
app.get('/secret-player', (req, res) => {
  if (players.length === 0) {
    return res.status(404).send({ error: 'Nenhum jogador disponível' });
  }

  const randomIndex = Math.floor(Math.random() * players.length);
  const secretPlayer = players[randomIndex];

  // Manda o evento de jogador secreto para o Event Bus 
  axios.post('http://localhost:3003/events', {
    type: 'Jogador Secreto Selecionado',
    data: secretPlayer
  }).catch((err) => {
    console.log('Erro ao enviar evento para o Event Bus', err.message);
  });

  res.status(200).send(secretPlayer);
});

const PORT = process.env.PORT || 3002;
app.listen(PORT, () => {
  console.log(`Serviço de jogador rodando na porta: ${PORT}`);
});
