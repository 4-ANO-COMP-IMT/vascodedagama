const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const { initializeApp } = require('firebase/app');
const { getAuth, signInWithEmailAndPassword, createUserWithEmailAndPassword, signOut } = require('firebase/auth');
const axios = require('axios');  // Importando o Axios para enviar eventos para o Event Bus
const dotenv = require('dotenv');
dotenv.config({path: "./.env"});

const firebaseConfig = {
  apiKey: process.env.FIREBASE_API_KEY,
  authDomain: process.env.FIREBASE_AUTH_DOMAIN,
  projectId: process.env.FIREBASE_PROJECT_ID,
  measurementId: process.env.FIREBASE_MEASUREMENT_ID,
  appId: process.env.FIREBASE_APP_ID,
  storageBucket: process.env.FIREBASE_STORAGE_BUCKET,
  messagingSenderId: process.env.FIREBASE_MESSAGING_SENDER_ID,
};

const firebaseApp = initializeApp(firebaseConfig);
const auth = getAuth(firebaseApp);

const app = express();
app.use(cors());
app.use(bodyParser.json());

app.post('/login', async (req, res) => {
  const { email, password } = req.body;

  try {
    const userCredential = await signInWithEmailAndPassword(auth, email, password);
    
    // Sorteia o jogador secreto
    const { data: secretPlayer } = await axios.get('http://playerservice-clusterip-service:3002/secret-player');

    // Manda o Evento pro Event Bus
    axios.post('http://eventbus-service:3003/events', {
      type: 'Usuario Logado',
      data: {
        id: userCredential.user.uid,
        email: userCredential.user.email,
        secretPlayer: secretPlayer // Inclui o jogador secreto no evento
      }
    }).catch((err) => {
      console.log('Erro enviando evento pro Event Bus', err.message);
    });

    res.status(200).send({
      user: userCredential.user,
      secretPlayer: secretPlayer // Envia o jogador secreto diretamente para o frontend
    });
  } catch (error) {
    res.status(400).send({ error: error.message });
  }
});

app.post('/signup', async (req, res) => {
  const { email, password } = req.body;

  try {
    const userCredential = await createUserWithEmailAndPassword(auth, email, password);
    
    // Sorteia o jogador secreto
    const { data: secretPlayer } = await axios.get('http://playerservice-clusterip-service:3002/secret-player');

    // Manda o Evento pro Event Bus
    axios.post('http://eventbus-service:3003/events', {
      type: 'Usuario Criado',
      data: {
        id: userCredential.user.uid,
        email: userCredential.user.email,
        secretPlayer: secretPlayer // Inclui o jogador secreto no evento
      }
    }).catch((err) => {
      console.log('Erro enviando evento pro Event Bus', err.message);
    });

    res.status(201).send({
      user: userCredential.user,
      secretPlayer: secretPlayer // Envia o jogador secreto diretamente para o frontend
    });
  } catch (error) {
    res.status(400).send({ error: error.message });
  }
});

app.post('/logout', (req, res) => {
  signOut(auth)
    .then(() => {
      // Manda o Evento pro Event Bus
      axios.post('http://eventbus-service:3003/events', {
        type: 'Usuario Deslogado',
        data: { message: 'Usuário deslogado com sucesso' }
      }).catch((err) => {
        console.log('Erro enviando evento pro Event Bus', err.message);
      });

      res.status(200).send({ message: 'Usuário deslogado com sucesso' });
    })
    .catch(error => {
      res.status(400).send({ error: error.message });
    });
});

app.post('/events', (req, res) => {
  console.log('Evento recebido:', req.body.type);
  res.send({});
});

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
  console.log(`Serviço de Autenticação rodando na porta: ${PORT}`);
});
