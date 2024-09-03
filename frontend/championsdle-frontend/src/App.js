import React, { useState, useEffect } from 'react';
import axios from 'axios';
import Login from './Components/Login/Login';
import './App.css';

const renderAttribute = (label, age, color, icon) => {
  const showIndicator = color.includes('red');
  const isHigher = color.includes('higher');
  const isLower = color.includes('lower');

  return (
    <div className={`player-attribute ${color}`}>
      {label === 'Nome' && icon && (
        <img src={icon} alt="Player Icon" className="player-icon" />
      )}
      {label !== 'Nome' && `${age}`}
      {showIndicator && (
        <span className="indicator">
          {isHigher ? '⬇️' : isLower ? '⬆️' : null}
        </span>
      )}
    </div>
  );
};

const App = () => {
  const [playerName, setPlayerName] = useState('');
  const [player, setPlayer] = useState(null);
  const [secretPlayer, setSecretPlayer] = useState(null);
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [showModal, setShowModal] = useState(false);
  const [isPalpitarDisabled, setIsPalpitarDisabled] = useState(false);
  const [suggestions, setSuggestions] = useState([]);
  const [guessHistory, setGuessHistory] = useState([]);
  const [guessedPlayers, setGuessedPlayers] = useState(new Set()); 
  const [attempts, setAttempts] = useState(0);
  const [score, setScore] = useState(0); 
  const [highScore, setHighScore] = useState(0);
  const [showRankingModal, setShowRankingModal] = useState(false);
  const [showHelpModal, setShowHelpModal] = useState(false);
  const [showOptions, setOptions] = useState(false);

  useEffect(() => {
    const loggedIn = localStorage.getItem('isLoggedIn');
    if (loggedIn === 'true') {
      setIsLoggedIn(true);
      setSecretPlayer(JSON.parse(localStorage.getItem('secretPlayer')));
      const savedHighScore = localStorage.getItem('highScore');
      if (savedHighScore) {
        setHighScore(parseInt(savedHighScore, 10));
      }
    }
  }, []);

  const fetchPlayers = async () => {
    try {
      const response = await axios.get('http://localhost:3002/players');
      return response.data;
    } catch (error) {
      console.error('Erro ao buscar jogadores:', error);
      return [];
    }
  };

  const handleShowRanking = () => {
    setShowRankingModal(true);
  };

  const handleCloseRankingModal = () => {
    setShowRankingModal(false);
  };

  const handleShowHelp = () => {
    setShowHelpModal(true);
  };

  const handleCloseHelpModal = () => {
    setShowHelpModal(false);
  };

  const handleInputChange = async (e) => {
    const input = e.target.value;
    setPlayerName(input);

    if (input.length > 0) {
      const players = await fetchPlayers();
      const filteredPlayers = players.filter(player => 
        player.name.toLowerCase().includes(input.toLowerCase()) &&
        !guessedPlayers.has(player.name) 
      );
      setSuggestions(filteredPlayers);
    } else {
      setSuggestions([]);
    }
  };

  const handleSuggestionClick = (suggestion) => {
    setPlayerName(suggestion.name);
    setSuggestions([]);
  };

  const handleSearch = async (e) => {
    e.preventDefault();
    try {
      const players = await fetchPlayers();
      const playerData = players.find(p => p.name.toLowerCase() === playerName.toLowerCase());
  
      if (playerData) {
        setPlayer(playerData);
        const newColor = checkAttributes(playerData);

        // Verifica se o jogador já foi palpitao e se ele é o jogador secreto
        if (!guessHistory.some(guess => guess.player.name === playerData.name) &&
            playerData.name.toLowerCase() !== secretPlayer.name.toLowerCase()) { 
          setAttempts(attempts + 1); // Incrementa a contagem de tentativas apenas se o jogador for diferente do secreto
        }
  
        // Adicionando o jogador ao histórico apenas se ele ainda não estiver lá
        if (!guessHistory.some(guess => guess.player.name === playerData.name)) {
          setGuessHistory(prevHistory => [
            { player: playerData, color: newColor }, // Adiciona o jogador no início do array
            ...prevHistory 
          ]);
          setGuessedPlayers(prevGuessedPlayers => new Set([...prevGuessedPlayers, playerData.name]));
        }

        if (playerData.name.toLowerCase() === secretPlayer.name.toLowerCase()) {
          setShowModal(true);
          setIsPalpitarDisabled(true);
          setScore(score + 1);
          if (score + 1 > highScore) {
            setHighScore(score + 1);
            localStorage.setItem('highScore', score + 1); 
          }
        } else if (attempts === 5) { // Verifica se é a última chance
          setShowModal(true);
          setIsPalpitarDisabled(true);
          setScore(0); 
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
      setShowModal(false);
      setIsPalpitarDisabled(false);
      setGuessHistory([]);
      setGuessedPlayers(new Set());
      setAttempts(0);
      setPlayerName('');
    } catch (error) {
      console.error('Erro ao sortear novo jogador:', error);
    }
  };

  const handleLogin = async (e) => {
    setSecretPlayer(secretPlayer);
    setIsLoggedIn(true);
  };

  const handleLogout = () => {
    localStorage.removeItem('isLoggedIn');
    localStorage.removeItem('secretPlayer');
    setIsLoggedIn(false);
    setSecretPlayer(null);
    setPlayer(null);
  };

  const checkAttributes = (playerData) => {
    const newColor = {};
    newColor.name = playerData.name === secretPlayer.name ? 'green' : 'red';
    if (playerData.height === secretPlayer.height) {
      newColor.height = 'green';
    } else {
      newColor.height = playerData.height > secretPlayer.height ? 'red higher' : 'red lower';
    }
    newColor.team = playerData.team === secretPlayer.team ? 'green' : 'red';
    if (playerData.age === secretPlayer.age) {
      newColor.age = 'green';
    } else {
      newColor.age = playerData.age > secretPlayer.age ? 'red higher' : 'red lower';
    }
    newColor.country = playerData.country === secretPlayer.country ? 'green' : 'red';
    newColor.position = playerData.position === secretPlayer.position ? 'green' : 'red';
    newColor.league = playerData.league === secretPlayer.league ? 'green' : 'red';
    return newColor; // Retorna o objeto de cores
  };

  if (!isLoggedIn) {
    return <Login onLoginSucess={handleLogin} />;
  } else {
    return (
      <main class="App-Main">
        <section class="App-Section">
          <div class="buttons-div">
            <button onClick={handleLogout}>Logout</button>
          </div>
          <div class="buttons-div">
            <button onClick={handleShowRanking}>Ranking</button>
            <button onClick={handleShowHelp}>Ajuda</button>
          </div>
        </section>
        <header class="App-Header">
          <h1>CHAMPIONSIDLE</h1>
        </header>
        <section class="App-Body">
        
        </section>
      </main>
    );
  }
};

export default App;