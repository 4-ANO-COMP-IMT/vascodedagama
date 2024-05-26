// Inicialize o Firebase


const firebaseConfig = {
    apiKey: "AIzaSyDtsNBgEVJ1NJ5GqX3PCvOYSzb-CTRLDaI",
    authDomain: "futdle.firebaseapp.com",
    projectId: "futdle",
    storageBucket: "futdle.appspot.com",
    messagingSenderId: "754585551605",
    appId: "1:754585551605:web:31d87a95a62c14e810bbbc",
    measurementId: "G-WC9N2M4DB9"
  };

firebase.initializeApp(firebaseConfig);

// Função para logar com email e senha
function loginWithEmailAndPassword() {
    const email = document.getElementById('email').value;
    const password = document.getElementById('password').value;

    firebase.auth().signInWithEmailAndPassword(email, password)
        .then((user) => {
            console.log('Usuário logado:', user);
            showUserInfo(user);
        })
        .catch((error) => {
            console.error('Erro ao logar:', error);
            alert('Erro ao logar: ' + error.message);
        });
}

// Função para criar um novo usuário com email e senha
function createUserWithEmailAndPassword() {
    const email = document.getElementById('new-email').value;
    const password = document.getElementById('new-password').value;

    firebase.auth().createUserWithEmailAndPassword(email, password)
        .then((user) => {
            console.log('Usuário criado:', user);
            showUserInfo(user);
        })
        .catch((error) => {
            console.error('Erro ao criar usuário:', error);
            alert('Erro ao criar usuário: ' + error.message);
        });
}

// Função para mostrar as informações do usuário logado
function showUserInfo(user) {
    document.getElementById('user-email').textContent = user.email;
    document.getElementById('login-form').style.display = 'none';
    document.getElementById('signup-form').style.display = 'none';
    document.getElementById('user-info').style.display = 'block';
}

// Função para deslogar o usuário
function signOut() {
    firebase.auth().signOut()
        .then(() => {
            console.log('Usuário deslogado');
            document.getElementById('user-email').textContent = '';
            document.getElementById('login-form').style.display = 'block';
            document.getElementById('signup-form').style.display = 'none';
            document.getElementById('user-info').style.display = 'none';
        })
        .catch((error) => {
            console.error('Erro ao deslogar:', error);
            alert('Erro ao deslogar: ' + error.message);
        });
}

// Função para mostrar o formulário de cadastro (opcional)
function showSignUpForm() {
    document.getElementById('login-form').style.display = 'none';
    document.getElementById('signup-form').style.display = 'block';
}

// Função para mostrar o formulário de login (opcional)
function showLoginForm() {
    document.getElementById('login-form').style.display = 'block';
    document.getElementById('signup-form').style.display = 'none';
}

// Verifique se o usuário está logado e mostre as informações adequadas
firebase.auth().onAuthStateChanged((user) => {
    if (user) {
        showUserInfo(user);
    } else {
        // Usuário não está logado, mostre o formulário de login
        document.getElementById('login-form').style.display = 'block';
    }
});

