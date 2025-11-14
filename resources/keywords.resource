*** Settings ***
Library    SeleniumLibrary
Library    RequestsLibrary
Library    OperatingSystem

*** Variables ***
${GEMINI_URL}=    https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent

*** Keywords ***

Preparar Ambiente
    Create Directory    ${DOWNLOAD_DIR}
    Open Browser    ${BASE_URL}    chrome    options=add_argument(--headless)

Finalizar Ambiente
    Close Browser

Acessar Página de Login
    Go To    ${BASE_URL}/login

Realizar Login Com Credenciais Válidas
    Input Text    id=username    ${LOGIN_USER}
    Input Text    id=password    ${LOGIN_PASSWORD}
    Click Button    xpath=//button[@type="submit"]

Validar Login Bem Sucedido
    Wait Until Page Contains    You logged into a secure area!

Acessar Página de Upload
    Go To    ${BASE_URL}/upload

Realizar Upload De Arquivo
    Choose File    id=file-upload    ${UPLOAD_FILE}
    Click Button    id=file-submit

Validar Upload Bem Sucedido
    Wait Until Page Contains    File Uploaded!

Acessar Página de Download
    Go To    ${BASE_URL}/download

Realizar Download De Arquivo
    Click Link    some-file.txt
    Sleep    3s

Validar Download
    File Should Exist    ${DOWNLOAD_DIR}/some-file.txt

Acessar Dynamic Loading
    Go To    ${BASE_URL}/dynamic_loading/1

Iniciar Dynamic Loading
    Click Button    xpath=//button

Validar Dynamic Loading
    Wait Until Page Contains    Hello World!

Enviar Resultado Para Gemini E Criar Issue Se Necessário
    ${log}=    Get Log File
    ${payload}=    Create Dictionary    contents=${log}

    Create Session    gemini    ${GEMINI_URL}
    ${response}=    Post Request    gemini    url=${GEMINI_URL}?key=${GEMINI_API_KEY}    json=${payload}

    Log    Gemini Response: ${response.text}

    Run Keyword If    'erro' in '${response.text}'    Criar Issue No GitHub    ${response.text}

Criar Issue No GitHub
    [Arguments]    ${erro}
    ${headers}=    Create Dictionary    Authorization=token ${MY_GITHUB_TOKEN}
    Create Session    github    https://api.github.com    headers=${headers}
    ${body}=    Create Dictionary    title=Erro Detectado nos Testes    body=${erro}
    Post Request    github    /repos/${GITHUB_REPO}/issues    json=${body}
