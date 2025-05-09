*** Settings ***
Library    SeleniumLibrary
Library    RequestsLibrary
Library    OperatingSystem
Library    String

*** Variables ***
# --- Página de Login Real ---
${LOGIN_URL}         https://senaigoias.com.br/portaldodocente/identificacao/
${BROWSER}           chrome
${USERNAME_FIELD}    name=txtLogin
${PASSWORD_FIELD}    name=txtSenha
${LOGIN_BUTTON}      xpath=//input[@type='submit' and @value='Entrar']

# --- Integração Gemini ---
${GEMINI_API_KEY}    %{GEMINI_TOKEN}
${GEMINI_ENDPOINT}   https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent

# --- Integração GitHub ---
${GITHUB_TOKEN}      %{MY_GITHUB_TOKEN}
${GITHUB_REPO}       Gabrielcarmop/robot-tests

*** Keywords ***
Fazer Login
    [Arguments]    ${username}    ${password}
    Go To    ${LOGIN_URL}
    Capture Page Screenshot    antes_do_wait.png
    Wait Until Element Is Visible    ${USERNAME_FIELD}    timeout=20s
    Capture Page Screenshot    depois_do_wait.png
    Input Text    ${USERNAME_FIELD}    ${username}
    Input Text    ${PASSWORD_FIELD}    ${password}
    Click Button    ${LOGIN_BUTTON}
    Sleep    2s

Checar Erro 401
    ${url_atual}    Get Location
    Run Keyword If    '${url_atual}' == '${LOGIN_URL}'
    ...    Log    Erro 401: login falhou - permanecemos na tela de login.
    ...    Capture Page Screenshot
    ...    Set Test Variable    ${erro}    Erro 401: Login não autorizado
    ...    Chamar Gemini e Criar Issue    ${erro}
    ...    Executar Plano B

Chamar Gemini e Criar Issue
    [Arguments]    ${error_message}
    ${commit_sha}     Get Environment Variable    GITHUB_SHA
    ${actor}          Get Environment Variable    GITHUB_ACTOR

    ${prompt}    Catenate
    ...    Você é um engenheiro DevOps. Ocorreu um erro de login no portal SESI.  \n
    ...    Erro: "${error_message}"\n
    ...    Commit: ${commit_sha}, Autor: ${actor}.\n
    ...    Liste 3 causas técnicas prováveis e 2 ações de debug rápido para resolver.

    ${ai_response}    Ask Gemini    ${prompt}
    Log    Resposta do Gemini: ${ai_response}    level=INFO
    Criar Issue no GitHub    Erro 401 no Login SESI    ${error_message}\n\nDiagnóstico:\n${ai_response}

Ask Gemini
    [Arguments]    ${prompt}
    ${headers}    Create Dictionary    Content-Type=application/json
    ${params}     Create Dictionary    key=${GEMINI_API_KEY}
    ${body}       Create Dictionary
    ...           contents=${{ [{"parts": [{"text": "${prompt}"}] }] }}
    ...           generationConfig=${{ {"temperature": 0.7} }}

    ${response}    POST    ${GEMINI_ENDPOINT}    json=${body}
    ...            headers=${headers}    params=${params}

    ${response_json}    Set Variable    ${response.json()}
    RETURN    ${response_json['candidates'][0]['content']['parts'][0]['text']}

Criar Issue no GitHub
    [Arguments]    ${title}    ${body}
    ${headers}    Create Dictionary
    ...    Authorization    Bearer ${GITHUB_TOKEN}
    ...    Accept    application/vnd.github.v3+json

    ${data}    Create Dictionary
    ...    title    ${title}
    ...    body    ${body}
    ...    labels    ${{ ["bug", "automatizado"] }}

    POST    https://api.github.com/repos/${GITHUB_REPO}/issues
    ...    json=${data}    headers=${headers}

Executar Plano B
    Log    Fluxo alternativo poderia usar login via API ou fallback.    level=INFO

*** Test Cases ***
Testar Login com Erro 401
    ${options}=    Create Dictionary
    Set To Dictionary    ${options}    --no-sandbox    --disable-dev-shm-usage    --headless    --window-size=1920,1080
    Open Browser    ${LOGIN_URL}    ${BROWSER}    options=${options}
    Fazer Login    usuario_invalido    senha_invalida
    Checar Erro 401
    Close Browser
