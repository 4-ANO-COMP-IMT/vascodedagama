import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './App.css';

const App = () => {
  const [playerName, setPlayerName] = useState('');
  const [player, setPlayer] = useState(null);
  const [secretPlayer, setSecretPlayer] = useState(null);
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [isCadastro, setCadastro] = useState(false);
  const [color, setColor] = useState({});
  const [showModal, setShowModal] = useState(false);
  const [isPalpitarDisabled, setIsPalpitarDisabled] = useState(false);

  useEffect(() => {
    const loggedIn = localStorage.getItem('isLoggedIn');
    if (loggedIn === 'true') {
      setIsLoggedIn(true);
      setSecretPlayer(JSON.parse(localStorage.getItem('secretPlayer')));
    }
  }, []);

  const handleSearch = async (e) => {
    e.preventDefault();
    try {
      const response = await axios.get('http://localhost:3002/players');
      const playerData = response.data.find(p => p.name.toLowerCase() === playerName.toLowerCase());

      if (playerData) {
        setPlayer(playerData);
        checkAttributes(playerData);

        if (playerData.name.toLowerCase() === secretPlayer.name.toLowerCase()) {
          setShowModal(true);
          setIsPalpitarDisabled(true);
        }
      } else {
        setPlayer(null);
        alert('Jogador não encontrado.');
      }
    } catch (error) {
      console.error('Erro ao buscar jogador:', error);
    }
  };

  const handleNewPlayer = async () => {
    try {
      const newSecretPlayer = await axios.get('http://localhost:3002/secret-player');
      setSecretPlayer(newSecretPlayer.data);
      localStorage.setItem('secretPlayer', JSON.stringify(newSecretPlayer.data));
      setPlayer(null);
      setColor({});
      setShowModal(false);
      setIsPalpitarDisabled(false);
    } catch (error) {
      console.error('Erro ao sortear novo jogador:', error);
    }
  };

  const handleLogin = async (e) => {
    e.preventDefault();
    try {
      const response = await axios.post('http://localhost:3001/login', {
        email: username,
        password: password
      });

      setIsLoggedIn(true);
      localStorage.setItem('isLoggedIn', 'true');
      setSecretPlayer(response.data.secretPlayer);
      localStorage.setItem('secretPlayer', JSON.stringify(response.data.secretPlayer));
      setIsPalpitarDisabled(false);
    } catch (error) {
      console.error('Erro ao fazer login:', error);
      alert('Usuário ou senha inválidos.');
    }
  };

  const handleLogout = () => {
    localStorage.removeItem('isLoggedIn');
    localStorage.removeItem('secretPlayer');
    setIsLoggedIn(false);
    setSecretPlayer(null);
    setPlayer(null);
    setColor({});
  };

  const handleCadastro = async (e) => {
    e.preventDefault();
    try {
      await axios.post('http://localhost:3001/signup', {
        email: username,
        password: password
      });
      alert('Cadastro realizado com sucesso! Faça login.');
      setCadastro(false);
    } catch (error) {
      console.error('Erro ao cadastrar:', error);
      alert('Erro ao realizar cadastro.');
    }
  };

  const checkAttributes = (playerData) => {
    const newColor = {};
    newColor.name = playerData.name === secretPlayer.name ? 'green' : 'red';
    newColor.height = playerData.height === secretPlayer.height ? 'green' : 'red';
    newColor.team = playerData.team === secretPlayer.team ? 'green' : 'red';
    newColor.price = playerData.price === secretPlayer.price ? 'green' : 'red';
    newColor.foot = playerData.foot === secretPlayer.foot ? 'green' : 'red';
    newColor.position = playerData.position === secretPlayer.position ? 'green' : 'red';
    newColor.league = playerData.league === secretPlayer.league ? 'green' : 'red';
    setColor(newColor);
  };

  if (isCadastro) {
    return (
      <div className="App">
        <header className="App-header">
          <h1>Cadastro</h1>
          <form onSubmit={handleCadastro}>
            <div className="input-container">
              <input
                className="form-input"
                type="text"
                placeholder="Username"
                value={username}
                onChange={(e) => setUsername(e.target.value)}
              />
              <input
                className="form-input"
                type="password"
                placeholder="Password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
              />
            </div>
            <div className="button-container">
              <button className="form-button" 
                onClick={(e) => { e.preventDefault(); setCadastro(false);
                }}>
                Voltar
              </button>
              <button className="form-button" type="submit">
                Cadastrar
              </button>
            </div>
          </form>
        </header>
      </div>
    );
  } if (!isLoggedIn) {
    return (
      <div className="App">
        <header className="App-header">
          <h1>Login</h1>
          <form onSubmit={handleLogin}>
            <div className="input-container">
              <input
                className="form-input"
                type="text"
                placeholder="Username"
                value={username}
                onChange={(e) => setUsername(e.target.value)}
              />
              <input
                className="form-input"
                type="password"
                placeholder="Password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
              />
            </div>
            <div className="button-container">
              <button className="form-button" 
                onClick={(e) => { e.preventDefault(); setCadastro(true);}}>
                Cadastro
              </button>
              <button className="form-button" type="submit">
                Login
              </button>
            </div>
          </form>
        </header>
      </div>
    );
  } else {
    return (
      <div className="App">
        <button className="logout-button" onClick={handleLogout}>
          Logout
        </button>
        <button onClick={handleNewPlayer} className="new-player-button">
          Novo Jogador
        </button>
        <h1>Championsdle</h1>
        <form onSubmit={handleSearch}>
          <input
            type="text"
            placeholder="Inserir nome de Jogador"
            value={playerName}
            onChange={(e) => setPlayerName(e.target.value)}
          />
          <button type="submit" disabled={isPalpitarDisabled}>Palpitar</button>
        </form>
        {player && (
          <div className="player-info">
            <img src={player.icon} alt={player.name} className="player-icon" />
            <div className="player-details">
              <div className={`player-attribute ${color.name}`}>
                Nome: {player.name}
              </div>
              <div className={`player-attribute ${color.height}`}>
                Altura: {player.height}
              </div>
              <div className={`player-attribute ${color.team}`}>
                Time: {player.team}
              </div>
              <div className={`player-attribute ${color.price}`}>
                Preço: {player.price}
              </div>
              <div className={`player-attribute ${color.foot}`}>
                Pé: {player.foot}
              </div>
              <div className={`player-attribute ${color.position}`}>
                Posição: {player.position}
              </div>
              <div className={`player-attribute ${color.league}`}>
                Liga: {player.league}
              </div>
            </div>
          </div>
        )}
        {showModal && (
          <div className="modal">
            <div className="modal-content">
              <h2>Parabéns!</h2>
              <p>Você acertou o jogador secreto!</p>
              <div className="button-container">
                <button onClick={() => setShowModal(false)}>Fechar</button>
                <button onClick={handleNewPlayer}>Novo Jogador</button>
              </div>
            </div>
          </div>
        )}
      </div>
    );
  }
};

export default App;
