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
${MENSAGEM_SUCESSO}  You logged into a secure area!

# --- Integração Gemini ---
${GEMINI_API_KEY}    AIzaSyB0EIY589GB0hxd4QiD2MDJfdlNAG-Htzk
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
    ...    Você é um engenheiro DevOps. Ocorreu um erro no portal.
    ...    Erro: "${error_message}"
    ...    Commit: ${commit_sha}, Autor: ${actor}.
    ...    Liste 3 causas técnicas prováveis e 2 ações de debug rápido para resolver.

    ${ai_response}=    Ask Gemini    ${prompt}
    Log    Resposta do Gemini: ${ai_response}    level=INFO
    Criar Issue no GitHub    Erro detectado no Login    ${error_message}\n\nDiagnóstico:\n${ai_response}

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


Testar Login com Sucesso
    Open Browser    ${LOGIN_URL}    ${BROWSER}
    Fazer Login    tomsmith    SuperSecretPassword!
    Page Should Contain    ${MENSAGEM_SUCESSO}
    Capture Page Screenshot
    Close Browser
    


# =======================================================
# 🚀 NOVOS TESTES (FUNCIONAM COM SUA ESTRUTURA ATUAL)
# =======================================================

Testar Checkboxes
    Open Browser    https://the-internet.herokuapp.com/checkboxes    ${BROWSER}
    Click Element    xpath=//form/input[1]
    ${checked}=    Get Element Attribute    xpath=//form/input[1]    checked

    IF    "${checked}" != "true"
        Chamar Gemini e Criar Issue    Checkbox não marcou corretamente
    END
    Close Browser


Testar Dropdown
    Open Browser    https://the-internet.herokuapp.com/dropdown    ${BROWSER}
    Select From List By Value    id=dropdown    2
    ${valor}=    Get Selected List Value    id=dropdown

    IF    "${valor}" != "2"
        Chamar Gemini e Criar Issue    Dropdown não selecionou corretamente
    END
    Close Browser


Testar Dynamic Loading
    Open Browser    https://the-internet.herokuapp.com/dynamic_loading/2    ${BROWSER}
    Click Button    css=#start button
    Wait Until Page Contains Element    id=finish    timeout=10s

    ${texto}=    Get Text    id=finish
    IF    "${texto}" != "Hello World!"
        Chamar Gemini e Criar Issue    Dynamic loading não retornou Hello World!
    END
    Close Browser


Testar Upload
    Open Browser    https://the-internet.herokuapp.com/upload    ${BROWSER}
    Create File    ${CURDIR}/arquivo.txt    teste upload
    Choose File    id=file-upload    ${CURDIR}/arquivo.txt
    Click Button    id=file-submit

    Page Should Contain    File Uploaded!
    Close Browser


Testar Imagens Quebradas
    Open Browser    https://the-internet.herokuapp.com/broken_images    ${BROWSER}

    @{imgs}=    Get WebElements    css=img

    FOR    ${img}    IN    @{imgs}
        ${w}=    Call Method    ${img}    get_attribute    naturalWidth
        IF    "${w}" == "0"
            Chamar Gemini e Criar Issue    Imagem quebrada detectada
        END
    END

    Close Browser


Testar Typos
    Open Browser    https://the-internet.herokuapp.com/typos    ${BROWSER}

    ${texto}=    Get Text    css=.example p

    IF    "typo" in "${texto}"
        Chamar Gemini e Criar Issue    Erro ortográfico encontrado na página
    END

    Close Browser