*** Settings ***
${GITHUB_API_URL} https://api.github.com/repos/${GITHUB_REPO}/issues

*** Keywords ***

Preparar Ambiente
Create Directory ${DOWNLOAD_DIR}
Open Browser ${BASE_URL} chrome options=add_argument(--headless); add_argument(--disable-gpu); add_argument(--no-sandbox); add_argument(--disable-dev-shm-usage)

Finalizar Ambiente
Close Browser

### LOGIN ###
Acessar Página de Login
Go To ${BASE_URL}/login

Realizar Login Com Credenciais Válidas
Input Text id=username ${LOGIN_USER}
Input Text id=password ${LOGIN_PASSWORD}
Click Button xpath=//button[@type="submit"]

Validar Login Bem Sucedido
Wait Until Page Contains You logged into a secure area!

### UPLOAD ###
Acessar Página de Upload
Go To ${BASE_URL}/upload

Realizar Upload De Arquivo
Choose File id=file-upload ${UPLOAD_FILE}
Click Button id=file-submit

Validar Upload Bem Sucedido
Wait Until Page Contains File Uploaded!

### DOWNLOAD ###
Acessar Página de Download
Go To ${BASE_URL}/download

Realizar Download De Arquivo
Click Link some-file.txt
Sleep 3s

Validar Download
File Should Exist ${DOWNLOAD_DIR}/some-file.txt

### DYNAMIC LOADING ###
Acessar Dynamic Loading
Go To ${BASE_URL}/dynamic_loading/1

Iniciar Dynamic Loading
Click Button xpath=//button

Validar Dynamic Loading
Wait Until Page Contains Hello World!

### GEMINI + GITHUB ###
Enviar Resultado Para Gemini E Criar Issue Se Necessário
${log}= Get Log
${payload}= Create Dictionary contents=${log}

Create Session gemini ${GEMINI_URL}
${response}= Post Request gemini url=${GEMINI_URL} json=${payload}

Log Gemini Response: ${response.text}

Run Keyword If "erro" in "${response.text}" Criar Issue No GitHub ${response.text}

Criar Issue No GitHub
[Arguments] ${erro}
Create Session github ${GITHUB_API_URL} headers={"Authorization": "token ${MY_GITHUB_TOKEN}"}
${body}= Create Dictionary title=Erro Detectado nos Testes body=${erro}
Post Request github ${GITHUB_API_URL} json=${body}