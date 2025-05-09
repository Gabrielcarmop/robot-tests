*** Settings ***
Library           SeleniumLibrary
Library           RequestsLibrary
Library           OperatingSystem
Library           String
Library           WebDriverManager

Suite Setup       Setup Browser
Suite Teardown    Close All Browsers

*** Variables ***
${LOGIN_URL}         https://sesigoias.com.br/portaldodocente/identificacao/
${BROWSER}           headlesschrome
${USERNAME_FIELD}    id=txtLogin
${PASSWORD_FIELD}    id=txtSenha
${LOGIN_BUTTON}      xpath=//input[@type='submit']

${GEMINI_API_KEY}    %{GEMINI_TOKEN}
${GEMINI_ENDPOINT}   https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent
${GITHUB_TOKEN}      %{GITHUB_TOKEN}
${GITHUB_REPO}       Gabrielcarmop/robot-tests

*** Keywords ***
Setup Browser
    ${chrome_options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys
    Call Method    ${chrome_options}    add_argument    --no-sandbox
    Call Method    ${chrome_options}    add_argument    --disable-dev-shm-usage
    Call Method    ${chrome_options}    add_argument    --headless
    Call Method    ${chrome_options}    add_argument    --disable-gpu
    Create WebDriver    Chrome    options=${chrome_options}
    Set Selenium Implicit Wait    10s
    Set Selenium Timeout    30s

Fazer Login
    [Arguments]    ${username}    ${password}
    Go To    ${LOGIN_URL}
    Wait Until Element Is Visible    ${USERNAME_FIELD}    15s
    Input Text    ${USERNAME_FIELD}    ${username}
    Input Text    ${PASSWORD_FIELD}    ${password}
    Click Button    ${LOGIN_BUTTON}
    Wait Until Location Is Not    ${LOGIN_URL}    15s

Checar Erro 401
    ${url_atual}    Get Location
    Run Keyword If    '${url_atual}' == '${LOGIN_URL}'
    ...    Run Keywords
    ...    Log    Erro 401: login falhou - permanecemos na tela de login.    level=WARN
    ...    AND    Capture Page Screenshot    filename=erro401.png
    ...    AND    Set Test Variable    ${erro}    Erro 401: Login não autorizado
    ...    AND    Chamar Gemini e Criar Issue    ${erro}
    ...    AND    Executar Plano B

Chamar Gemini e Criar Issue
    [Arguments]    ${error_message}
    ${commit_sha}     Get Environment Variable    GITHUB_SHA    default=None
    ${actor}          Get Environment Variable    GITHUB_ACTOR    default=Unknown
    ${prompt}    Catenate    SEPARATOR=\n
    ...    Você é um engenheiro DevOps. Ocorreu um erro de login no portal SESI.
    ...    Erro: "${error_message}"
    ...    Commit: ${commit_sha}, Autor: ${actor}.
    ...    Liste 3 causas técnicas prováveis e 2 ações de debug rápido para resolver.
    
    ${ai_response}    Ask Gemini    ${prompt}
    Log    Resposta do Gemini: ${ai_response}    level=INFO
    Criar Issue no GitHub    Erro 401 no Login SESI    ${error_message}\n\nDiagnóstico:\n${ai_response}

Ask Gemini
    [Arguments]    ${prompt}
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${params}=     Create Dictionary    key=${GEMINI_API_KEY}
    ${body}=       Create Dictionary
    ...            contents=${{ [{"parts": [{"text": "${prompt}"}] }] }}
    ...            generationConfig=${{ {"temperature": 0.7} }}
    
    ${response}=    POST    ${GEMINI_ENDPOINT}    json=${body}
    ...             headers=${headers}    params=${params}
    ...             timeout=30
    ${response_json}=    Set Variable    ${response.json()}
    [Return]    ${response_json['candidates'][0]['content']['parts'][0]['text']}

Criar Issue no GitHub
    [Arguments]    ${title}    ${body}
    ${headers}=    Create Dictionary
    ...            Authorization=Bearer ${GITHUB_TOKEN}
    ...            Accept=application/vnd.github.v3+json
    
    ${data}=    Create Dictionary
    ...         title=${title}
    ...         body=${body}
    ...         labels=${{ ["bug", "automatizado"] }}
    
    POST    https://api.github.com/repos/${GITHUB_REPO}/issues
    ...     json=${data}    headers=${headers}
    ...     timeout=10

Executar Plano B
    Log    Fluxo alternativo poderia usar login via API ou fallback.    level=INFO

*** Test Cases ***
Testar Login com Erro 401
    Fazer Login    usuario_invalido    senha_invalida
    Checar Erro 401