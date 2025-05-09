*** Settings ***
Library    SeleniumLibrary
Library    RequestsLibrary
Library    OperatingSystem
Library    String
Library    Collections

*** Variables ***
# --- Página de Login ---
${LOGIN_URL}         https://senaigoias.com.br/portaldodocente/identificacao/
${BROWSER}           chrome
${USERNAME_FIELD}    name=txtLogin
${PASSWORD_FIELD}    name=txtSenha
${LOGIN_BUTTON}      xpath=//input[@type='submit' and @value='Entrar']
${PAGE_TITLE}        Portal do Docente

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
    
    Run Keyword If    ${HEADLESS}    Call Method    ${chrome_options}    add_argument    --headless=new
    Call Method    ${chrome_options}    add_argument    --window-size\=${BROWSER_WIDTH},${BROWSER_HEIGHT}
    
    Create WebDriver    Chrome    options=${chrome_options}
    Set Selenium Implicit Wait    10s
    Set Selenium Timeout    30s

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

# Restante das keywords permanecem iguais...

*** Test Cases ***
Testar Login com Erro 401
    [Documentation]    Testa o cenário de login inválido retornando erro 401
    [Tags]    login    auth    erro401
    
    Abrir Navegador
    Fazer Login    usuario_invalido    senha_invalida
    Checar Erro 401
    [Teardown]    Close All Browsers