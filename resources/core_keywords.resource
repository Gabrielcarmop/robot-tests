*** Settings ***
Library    SeleniumLibrary
Library    RequestsLibrary
Library    OperatingSystem
Library    String
Library    Collections

*** Variables ***
# --- URLs ---
${LOGIN_URL}         https://the-internet.herokuapp.com/login

# --- Config ---
${BROWSER}           chrome

# --- Elementos do Login ---
${USERNAME_FIELD}    id=username
${PASSWORD_FIELD}    id=password
${LOGIN_BUTTON}      xpath=//button[@type='submit']
${MENSAGEM_ERRO}     Your password is invalid!
${MENSAGEM_SUCESSO}  You logged into a secure area!

# --- Integração Gemini ---
${GEMINI_API_KEY}    AIzaSyB0EIY589GB0hxd4QiD2MDJfdlNAG-Htzk
${GEMINI_ENDPOINT}   https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent

# --- Integração GitHub ---
${GITHUB_TOKEN}      %{MY_GITHUB_TOKEN}
${GITHUB_REPO}       Gabrielcarmop/robot-tests



*** Keywords ***
Abrir Página de Login
    Open Browser    ${LOGIN_URL}    ${BROWSER}
    Maximize Browser Window

Inputar Usuário
    [Arguments]    ${usuario}
    Input Text    ${USERNAME_FIELD}    ${usuario}

Inputar Senha
    [Arguments]    ${senha}
    Input Text    ${PASSWORD_FIELD}    ${senha}

Enviar Formulário
    Click Button    ${LOGIN_BUTTON}
    Sleep    1s

Fechar Navegador
    Close Browser



# ======================================================
#                FLUXO DE LOGIN
# ======================================================
Fazer Login
    [Arguments]    ${username}    ${password}
    Go To    ${LOGIN_URL}
    Inputar Usuário    ${username}
    Inputar Senha      ${password}
    Enviar Formulário



Checar Erro 401
    Page Should Contain    ${MENSAGEM_ERRO}
    Capture Page Screenshot
    Chamar Gemini e Criar Issue    Erro 401: Credenciais inválidas detectadas.



# ======================================================
#             INTEGRAÇÃO GEMINI
# ======================================================
Ask Gemini
    [Arguments]    ${prompt}

    TRY
        ${headers}=    Create Dictionary    Content-Type=application/json
        ${params}=     Create Dictionary    key=${GEMINI_API_KEY}

        ${part}=       Create Dictionary    text=${prompt}
        ${content}=    Create Dictionary    role=user    parts=${part}
        ${contents}=   Create List          ${content}
        ${gen_conf}=   Create Dictionary    temperature=0.7

        ${body}=       Create Dictionary
        ...    contents=${contents}
        ...    generationConfig=${gen_conf}

        ${response}=   POST
        ...    ${GEMINI_ENDPOINT}
        ...    json=${body}
        ...    headers=${headers}
        ...    params=${params}

        ${json}=    Set Variable    ${response.json()}
        RETURN    ${json['candidates'][0]['content']['parts'][0]['text']}

    EXCEPT    Exception as err
        Log    Falha ao chamar Gemini: ${err}    level=ERROR
        RETURN    Falha ao consultar Gemini
    END



# ======================================================
#            INTEGRAÇÃO GITHUB
# ======================================================
Criar Issue no GitHub
    [Arguments]    ${title}    ${body}

    ${headers}=    Create Dictionary
    ...    Authorization=Bearer ${GITHUB_TOKEN}
    ...    Accept=application/vnd.github.v3+json

    ${payload}=    Create Dictionary
    ...    title=${title}
    ...    body=${body}
    ...    labels=${{ ["bug","automatizado"] }}

    POST    https://api.github.com/repos/${GITHUB_REPO}/issues
    ...     json=${payload}
    ...     headers=${headers}



Chamar Gemini e Criar Issue
    [Arguments]    ${mensagem}

    ${commit}=    Get Environment Variable    GITHUB_SHA    default=commit_desconhecido
    ${autor}=     Get Environment Variable    GITHUB_ACTOR   default=autor_desconhecido

    ${prompt}=    Catenate    SEPARATOR=\n
    ...    Analisar erro no teste automatizado.
    ...    Erro: ${mensagem}
    ...    Commit: ${commit}
    ...    Autor: ${autor}
    ...    Liste causas prováveis e passos imediatos de diagnóstico.

    ${analise}=   Ask Gemini    ${prompt}

    Criar Issue no GitHub
    ...    Erro detectado automaticamente
    ...    ${mensagem}\n\nDiagnóstico Gemini:\n${analise}
