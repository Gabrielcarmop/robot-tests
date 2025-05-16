*** Settings ***
Library    SeleniumLibrary
Library    RequestsLibrary
Library    OperatingSystem
Library    String
Library    Collections

*** Variables ***
# --- Página de Login ---
${LOGIN_URL}         https://the-internet.herokuapp.com/login
${BROWSER}           chrome
${USERNAME_FIELD}    id=username
${PASSWORD_FIELD}    id=password
${LOGIN_BUTTON}      xpath=//button[@type='submit']
${MENSAGEM_ERRO}     Your password is invalid!

# --- Integração Gemini ---
# 🔥 CHAVE DIRETA PARA TESTES – REMOVA APÓS USO EM PROD 🔥
${GEMINI_API_KEY}    AIzaSyDO_dTrhS5xcYZGINmOM2l8C16vYvot-fI
${GEMINI_ENDPOINT}   https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent

# --- Integração GitHub ---
${GITHUB_TOKEN}      %{MY_GITHUB_TOKEN}
${GITHUB_REPO}       Gabrielcarmop/robot-tests

*** Keywords ***
Fazer Login
    [Arguments]    ${username}    ${password}
    Go To    ${LOGIN_URL}
    Input Text    ${USERNAME_FIELD}    ${username}
    Input Text    ${PASSWORD_FIELD}    ${password}
    Click Button    ${LOGIN_BUTTON}
    Sleep    2s

Checar Erro 401
    Page Should Contain    ${MENSAGEM_ERRO}
    Log    Erro 401: login falhou - mensagem de erro visível.
    Capture Page Screenshot
    Set Test Variable    ${erro}    Erro 401: Login não autorizado
    Chamar Gemini e Criar Issue    ${erro}
    Executar Plano B

Chamar Gemini e Criar Issue
    [Arguments]    ${error_message}
    ${commit_sha}=    Get Environment Variable    GITHUB_SHA    default=commit_desconhecido
    ${actor}=         Get Environment Variable    GITHUB_ACTOR    default=autor_desconhecido

    ${prompt}=    Catenate    SEPARATOR=\n
    ...    Você é um engenheiro DevOps. Ocorreu um erro de login no portal.
    ...    Erro: "${error_message}"
    ...    Commit: ${commit_sha}, Autor: ${actor}.
    ...    Liste 3 causas técnicas prováveis e 2 ações de debug rápido para resolver.

    ${ai_response}=    Ask Gemini    ${prompt}
    Log    Resposta do Gemini: ${ai_response}    level=INFO
    Criar Issue no GitHub    Erro 401 no Login    ${error_message}\n\nDiagnóstico:\n${ai_response}
Ask Gemini
    [Arguments]    ${prompt}
    TRY
        ${headers}=    Create Dictionary    Content-Type=application/json
        ${params}=     Create Dictionary    key=${GEMINI_API_KEY}

        ${part}=       Create Dictionary    text=${prompt}
        ${parts}=      Create List          ${part}
        ${content}=    Create Dictionary    role=user    parts=${parts}
        ${contents}=   Create List          ${content}
        ${gen_config}=    Create Dictionary    temperature=0.7

        ${body_dict}=    Create Dictionary
        ...    contents=${contents}
        ...    generationConfig=${gen_config}

        ${response}=    POST    ${GEMINI_ENDPOINT}
        ...             json=${body_dict}
        ...             headers=${headers}
        ...             params=${params}
        ...             expected_status=200

        ${response_json}=    Set Variable    ${response.json()}
        RETURN    ${response_json['candidates'][0]['content']['parts'][0]['text']}

    EXCEPT    Exception as error
        Log    Falha ao chamar Gemini: ${error}    level=ERROR
        RETURN    Erro na comunicação com a API Gemini
    END

Criar Issue no GitHub
    [Arguments]    ${title}    ${body}
    ${headers}=    Create Dictionary
    ...    Authorization=Bearer ${GITHUB_TOKEN}
    ...    Accept=application/vnd.github.v3+json

    ${data}=    Create Dictionary
    ...    title=${title}
    ...    body=${body}
    ...    labels=${{ ["bug", "automatizado"] }}

    POST    https://api.github.com/repos/${GITHUB_REPO}/issues
    ...    json=${data}    headers=${headers}

Executar Plano B
    Log    Fluxo alternativo poderia usar login via API ou fallback.    level=INFO

*** Test Cases ***
Testar Login com Erro 401
    Open Browser    ${LOGIN_URL}    ${BROWSER}
    Fazer Login    tomsmith    senha_invalida
    Checar Erro 401
    Close Browser
