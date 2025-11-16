*** Settings ***
Library    SeleniumLibrary
Library    RequestsLibrary
Library    OperatingSystem
Library    String
Library    Collections

Suite Setup       Inicializar Suite
Suite Teardown    Finalizar Suite
Test Setup        Preparar Teste
Test Teardown     Finalizar Teste

*** Variables ***
# --- URLs ---
${LOGIN_URL}               https://the-internet.herokuapp.com/login
${CHECKBOXES_URL}         https://the-internet.herokuapp.com/checkboxes
${DROPDOWN_URL}           https://the-internet.herokuapp.com/dropdown
${FILE_UPLOAD_URL}        https://the-internet.herokuapp.com/upload
${JS_ALERTS_URL}          https://the-internet.herokuapp.com/javascript_alerts
${DYNAMIC_LOADING_URL}    https://the-internet.herokuapp.com/dynamic_loading/2

${AUTH_URL}               https://admin:admin@the-internet.herokuapp.com/basic_auth

# --- Configurações ---
${BROWSER}              chrome
${TIMEOUT}              10s

# --- Integração Gemini ---
${GEMINI_API_KEY}    AIzaSyB0EIY589GB0hxd4QiD2MDJfdlNAG-Htzk
${GEMINI_ENDPOINT}   https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent

# --- Integração GitHub ---
${GITHUB_TOKEN}      %{MY_GITHUB_TOKEN}
${GITHUB_REPO}       Gabrielcarmop/robot-tests


*** Keywords ***
Inicializar Suite
    Log    Iniciando suíte de testes.

Finalizar Suite
    Log    Finalizando suíte.

Preparar Teste
    Log    Iniciando caso de teste.
    # Abertura será definida pelo próprio teste

Finalizar Teste
    Run Keyword If Test Failed    Tratar Falha
    Close Browser

Tratar Falha
    Capture Page Screenshot
    ${mensagem}=    Set Variable    Falha no teste: ${TEST NAME}\nMensagem: ${TEST MESSAGE}
    Log    ${mensagem}
    Chamar Gemini e Criar Issue    ${mensagem}


# ------------------------
#      GEMINI + GITHUB
# ------------------------
Chamar Gemini e Criar Issue
    [Arguments]    ${error_message}
    ${commit_sha}=    Get Environment Variable    GITHUB_SHA    default=commit_desconhecido
    ${actor}=         Get Environment Variable    GITHUB_ACTOR    default=autor_desconhecido

    ${prompt}=    Catenate    SEPARATOR=\n
    ...    Análise técnica automática de erro no portal.
    ...    Erro: "${error_message}"
    ...    Commit: ${commit_sha}, Autor: ${actor}.
    ...    Liste 3 causas técnicas prováveis e 2 ações de debug rápido.

    ${ai_response}=    Ask Gemini    ${prompt}
    Create Issue no GitHub    Falha no teste: ${TEST NAME}    ${error_message}\n\nDiagnóstico automático:\n${ai_response}

Ask Gemini
    [Arguments]    ${prompt}

    ${headers}=    Create Dictionary    Content-Type=application/json
    ${params}=     Create Dictionary    key=${GEMINI_API_KEY}

    ${part}=       Create Dictionary    text=${prompt}
    ${parts}=      Create List          ${part}
    ${content}=    Create Dictionary    role=user    parts=${parts}
    ${contents}=   Create List          ${content}
    ${gen_config}=    Create Dictionary    temperature=0.7

    ${body}=    Create Dictionary    contents=${contents}    generationConfig=${gen_config}

    ${response}=    POST    ${GEMINI_ENDPOINT}
    ...    json=${body}
    ...    headers=${headers}
    ...    params=${params}
    ...    expected_status=200

    ${json}=    Set Variable    ${response.json()}
    RETURN    ${json['candidates'][0]['content']['parts'][0]['text']}

Create Issue no GitHub
    [Arguments]    ${title}    ${body}

    ${headers}=    Create Dictionary
    ...    Authorization=Bearer ${GITHUB_TOKEN}
    ...    Accept=application/vnd.github.v3+json

    ${data}=    Create Dictionary
    ...    title=${title}
    ...    body=${body}
    ...    labels=${{ ["bug", "automatizado"] }}

    POST    https://api.github.com/repos/${GITHUB_REPO}/issues
    ...    json=${data}
    ...    headers=${headers}


# ------------------------
#       TESTES
# ------------------------

# -------- TESTE DE LOGIN --------
Testar Login com Erro 401
    Open Browser    ${LOGIN_URL}    ${BROWSER}
    Input Text    id=username    tomsmith
    Input Text    id=password    senha_invalida
    Click Button    xpath=//button[@type='submit']
    Wait Until Page Contains    Your password is invalid!    timeout=5s

Testar Login com Sucesso
    Open Browser    ${LOGIN_URL}    ${BROWSER}
    Input Text    id=username    tomsmith
    Input Text    id=password    SuperSecretPassword!
    Click Button    xpath=//button[@type='submit']
    Wait Until Page Contains    You logged into a secure area!


# -------- TESTE CHECKBOXES --------
Testar Checkboxes
    Open Browser    ${CHECKBOXES_URL}    ${BROWSER}
    Click Element    xpath=(//input[@type='checkbox'])[1]
    Click Element    xpath=(//input[@type='checkbox'])[2]
    Capture Page Screenshot


# -------- TESTE DROPDOWN --------
Testar Dropdown
    Open Browser    ${DROPDOWN_URL}    ${BROWSER}
    Select From List By Value    id=dropdown    1
    Page Should Contain Element    xpath=//option[@value='1' and @selected]


# -------- TESTE DE UPLOAD --------
Testar Upload de Arquivo
    ${arquivo}=    Set Variable    ${CURDIR}/teste_upload.txt
    Create File    ${arquivo}    Arquivo gerado automaticamente.
    Open Browser    ${FILE_UPLOAD_URL}    ${BROWSER}
    Choose File    id=file-upload    ${arquivo}
    Click Button    id=file-submit
    Wait Until Page Contains    File Uploaded!


# -------- TESTE DE ALERTAS --------
Testar Alerts
    Open Browser    ${JS_ALERTS_URL}    ${BROWSER}
    Click Button    xpath=//button[text()='Click for JS Alert']
    Handle Alert    ACCEPT
    Click Button    xpath=//button[text()='Click for JS Confirm']
    Handle Alert    CANCEL
    Click Button    xpath=//button[text()='Click for JS Prompt']
    Input Text Into Alert    Teste
    Handle Alert    ACCEPT


# -------- TESTE DE DYNAMIC LOADING --------
Testar Dynamic Loading
    Open Browser    ${DYNAMIC_LOADING_URL}    ${BROWSER}
    Click Button    xpath=//div[@id='start']/button
    Wait Until Page Contains    Hello World!    timeout=10s


# -------- TESTE DE BASIC AUTH --------
Testar Basic Auth
    Open Browser    ${AUTH_URL}    ${BROWSER}
    Wait Until Page Contains    Congratulations!
