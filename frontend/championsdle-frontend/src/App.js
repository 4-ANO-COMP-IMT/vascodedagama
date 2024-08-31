import React, { useState, useEffect } from 'react';
import axios from 'axios';
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
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [isCadastro, setCadastro] = useState(false);
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
        const newColor = checkAttributes(playerData); // Calcula as cores do jogador

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
        <button onClick={handleShowRanking} className="ranking-button">
          Ranking
        </button>
        <button onClick={handleShowHelp} className="help-button">
          Ajuda
        </button>
        {/* Exibindo informações de tentativas */}
        {guessHistory.length > 0 && (
        <p className="attempts-info">
          {attempts >= 6 ? 'O jogador secreto não foi adivinhado.' :
            player && player.name.toLowerCase() === secretPlayer.name.toLowerCase() ? 
            `Você acertou o jogador secreto: ${secretPlayer.name}!` : 
            `Você possui ${6 - attempts} tentativas restantes.`
          }
        </p>)}
        {/* Exibindo a pontuação atual e recorde */}
        <div className="score-container">
          <p>Pontuação: {score}</p>
        </div>
        <div className="high-score-container">
          <p>Recorde: {highScore}</p> 
        </div>
        <h1>Championsdle</h1>
        <form onSubmit={handleSearch}>
          <input
            type="text"
            placeholder="Inserir nome de Jogador"
            value={playerName}
            onChange={handleInputChange}
            className="player-input"
          />
          <button type="submit" disabled={isPalpitarDisabled}>Palpitar</button>
        </form>
        {suggestions.length > 0 && (
          <ul className="suggestions-list">
            {suggestions.map((suggestion) => (
              <li
                key={suggestion.name}
                onClick={() => handleSuggestionClick(suggestion)}
              >
                <img src={suggestion.icon} alt={suggestion.name} className="suggestion-icon" />
                <span>{suggestion.name}</span>
                <img src={suggestion.club_logo} alt={suggestion.club_logo} className="suggestion-club" />
              </li>
            ))}
          </ul>
        )}
        {/* Linha de cabeçalho com os rótulos dos atributos */}
        {guessHistory.length > 0 && (
        <div className="attribute-header">
          <div>Jogador</div>
          <div>Altura</div>
          <div>Time</div>
          <div>Idade</div>
          <div>Nacionalidade</div>
          <div>Posição</div>
          <div>Liga</div>
        </div>)}
        {/* Exibindo o histórico dos palpites */}
        <div className="guess-history">
          {guessHistory.map((guess, index) => (
            <div key={index} className="player-info">
              <div className="player-details">
                {/* Renderizando os atributos do jogador, cada um em uma linha separada */}
                <div className="player-attribute">
                  {renderAttribute('Nome', guess.player.name, guess.color.name, guess.player.icon)}
                </div>
                <div className="player-attribute">
                  {renderAttribute('Altura', guess.player.height, guess.color.height)}
                </div>
                <div className="player-attribute">
                  {renderAttribute('Time', guess.player.team, guess.color.team)}
                </div>
                <div className="player-attribute">
                  {renderAttribute('Idade', guess.player.age, guess.color.age)}
                </div>
                <div className="player-attribute">
                  {renderAttribute('Nacionalidade', guess.player.country, guess.color.country)}
                </div>
                <div className="player-attribute">
                  {renderAttribute('Posição', guess.player.position, guess.color.position)}
                </div>
                <div className="player-attribute">
                  {renderAttribute('Liga', guess.player.league, guess.color.league)}
                </div>
              </div>
            </div>
          ))}
        </div>
        {showHelpModal && (
          <div className="modal">
            <div className="modal-content">
              <h2>Como Jogar</h2>
              <p>
                O Championsdle é um jogo que desafia você a adivinhar um jogador secreto de futebol.
                Você tem seis tentativas para descobrir quem é o jogador, usando as dicas fornecidas.
                Após cada palpite, você receberá dicas sobre os atributos do jogador.
              </p>
              <p>
                <b>Dicas:</b>
              </p>
              <ul>
                <li>
                  <b>Verde:</b>  Significa que o atributo está correto.
                </li>
                <li>
                  <b>Vermelho:</b>  Significa que o atributo está incorreto.
                </li>
                <li>
                  <b>Vermelho com seta para baixo (⬇️):</b>  Significa que o atributo é maior do que o do jogador secreto.
                </li>
                <li>
                  <b>Vermelho com seta para cima (⬆️):</b> Significa que o atributo é menor do que o do jogador secreto.
                </li>
              </ul>
              <button onClick={handleCloseHelpModal}>Fechar</button>
            </div>
          </div>
        )}
        {/* Protótipo de ranking, quando for adicionado banco de dados ele terá funcionalidade */}
        {showRankingModal && (
          <div className="modal">
            <div className="modal-content">
              <h2>Carregando ranking...</h2>
              <button onClick={handleCloseRankingModal}>Fechar</button>
            </div>
          </div>
        )}
        {showModal && (
          <div className="modal">
            <div className="modal-content">
            {attempts >= 6 && (
                <h2>Você não adivinhou o jogador secreto!</h2>
              )}
              {attempts < 6 && player && player.name.toLowerCase() === secretPlayer.name.toLowerCase() && (
                <h2>Parabéns!</h2>
              )}
              <p>
                {attempts >= 6 ? 'O jogador secreto não foi adivinhado.' :
                  player && player.name.toLowerCase() === secretPlayer.name.toLowerCase() ? 
                  `Você acertou o jogador secreto: ${secretPlayer.name}!` : 
                  null
                }
              </p>
              <button onClick={handleNewPlayer}>Sortear Novo Jogador</button>
            </div>
          </div>
        )}
      </div>
    );
  }
};

export default App;