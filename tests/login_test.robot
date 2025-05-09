*** Settings ***
Library    SeleniumLibrary
Library    RequestsLibrary
Library    OperatingSystem
Library    String
Library    Collections

*** Variables ***
# --- Página de Login ---
${LOGIN_URL}         http://the-internet.herokuapp.com/login
${BROWSER}           chrome
${USERNAME_FIELD}    id=username
${PASSWORD_FIELD}    id=password
${LOGIN_BUTTON}      xpath=//button[@type='submit']
${PAGE_TITLE}        Login Page

# --- Configurações do Navegador ---
${HEADLESS}          ${True}
${BROWSER_WIDTH}     1920
${BROWSER_HEIGHT}    1080

# --- Integrações ---
${GEMINI_API_KEY}    %{GEMINI_TOKEN}
${GEMINI_ENDPOINT}   https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent
${GITHUB_TOKEN}      %{MY_GITHUB_TOKEN}
${GITHUB_REPO}       Gabrielcarmop/robot-tests

*** Keywords ***
Abrir Navegador
    ${chrome_options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    Call Method    ${chrome_options}    add_argument    --no-sandbox
    Call Method    ${chrome_options}    add_argument    --disable-dev-shm-usage
    
    Run Keyword If    ${HEADLESS}    Call Method    ${chrome_options}    add_argument    --headless
    # Ajuste para adicionar o tamanho da janela
    Call Method    ${chrome_options}    add_argument    --window-size=${BROWSER_WIDTH}x${BROWSER_HEIGHT}
    
    Create WebDriver    Chrome    options=${chrome_options}
    Set Selenium Implicit Wait    10s
    Set Selenium Timeout    30s
    Maximize Browser Window

Fazer Login
    [Arguments]    ${username}    ${password}
    Go To    ${LOGIN_URL}
    Wait Until Page Contains    ${PAGE_TITLE}    timeout=30s
    Capture Page Screenshot    antes_do_login.png
    
    Wait Until Keyword Succeeds    3x    5s    Preencher Credenciais    ${username}    ${password}
    
    Click Button    ${LOGIN_BUTTON}
    Sleep    2s
    Capture Page Screenshot    depois_do_login.png

Preencher Credenciais
    [Arguments]    ${username}    ${password}
    Wait Until Element Is Visible    ${USERNAME_FIELD}    timeout=20s
    Input Text    ${USERNAME_FIELD}    ${username}
    Wait Until Element Is Visible    ${PASSWORD_FIELD}    timeout=5s
    Input Password    ${PASSWORD_FIELD}    ${password}

Checar Erro 401
    ${url_atual}=    Get Location
    Run Keyword If    '${url_atual}' == '${LOGIN_URL}'
    ...    Run Keywords
    ...    Log    Erro 401: login falhou - permanecemos na tela de login.    level=WARN
    ...    AND    Capture Page Screenshot    erro_401.png
    ...    AND    Set Test Variable    ${erro}    Erro 401: Login não autorizado
    ...    AND    Chamar Gemini e Criar Issue    ${erro}
    ...    AND    Executar Plano B

Chamar Gemini e Criar Issue
    [Arguments]    ${error_message}
    ${commit_sha}=    Get Environment Variable    GITHUB_SHA    default=unknown
    ${actor}=        Get Environment Variable    GITHUB_ACTOR    default=unknown

    ${prompt}=    Catenate    SEPARATOR=\n
    ...    Você é um engenheiro DevOps. Ocorreu um erro de login no portal SESI.
    ...    Erro: "${error_message}"
    ...    Commit: ${commit_sha}, Autor: ${actor}.
    ...    Liste 3 causas técnicas prováveis e 2 ações de debug rápido para resolver.

    ${ai_response}=    Ask Gemini    ${prompt}
    Log    Resposta do Gemini: ${ai_response}    level=INFO
    Criar Issue no GitHub    Erro 401 no Login SESI    ${error_message}\n\nDiagnóstico:\n${ai_response}

Ask Gemini
    [Arguments]    ${prompt}
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${params}=     Create Dictionary    key=${GEMINI_API_KEY}
    ${body}=       Evaluate    json.dumps({"contents": [{"parts": [{"text": "${prompt}"}]}], "generationConfig": {"temperature": 0.7}})    json

    ${response}=    POST    ${GEMINI_ENDPOINT}    json=${body}
    ...            headers=${headers}    params=${params}

    ${response_json}=    Set Variable    ${response.json()}
    RETURN    ${response_json['candidates'][0]['content']['parts'][0]['text']}

Criar Issue no GitHub
    [Arguments]    ${title}    ${body}
    ${headers}=    Create Dictionary
    ...    Authorization=Bearer ${GITHUB_TOKEN}
    ...    Accept=application/vnd.github.v3+json

    ${data}=    Create Dictionary
    ...    title=${title}
    ...    body=${body}
    ...    labels=${{ ["bug", "automatizado"] }}

    ${response}=    POST    https://api.github.com/repos/${GITHUB_REPO}/issues
    ...             json=${data}    headers=${headers}
    ...             expected_status=201

    Log    Issue criado com sucesso: ${response.json()['html_url']}    level=INFO

Executar Plano B
    Log    Fluxo alternativo poderia usar login via API ou fallback.    level=INFO

*** Test Cases ***
Testar Login com Erro 401
    [Documentation]    Testa o cenário de login inválido retornando erro 401
    [Tags]    login    auth    erro401
    
    Abrir Navegador
    Fazer Login    tomsmith    invalidpassword
    Checar Erro 401
    [Teardown]    Close All Browsers
