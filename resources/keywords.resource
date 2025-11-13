*** Settings ***
Library           SeleniumLibrary
Library           RequestsLibrary
Library           OperatingSystem

*** Variables ***
${BASE_URL}                https://the-internet.herokuapp.com
${GITHUB_API}              https://api.github.com/repos/${GITHUB_REPO}/issues
${GITHUB_TOKEN}            ${MY_GITHUB_TOKEN}
${GEMINI_URL}              https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent
${GEMINI_KEY}              ${GEMINI_API_KEY}

${BROWSER}                 chrome
${LOG_FILE}                logs.txt

*** Keywords ***
Preparar Ambiente
    Create Session    github    ${GITHUB_API}    headers={"Authorization": "Bearer ${GITHUB_TOKEN}","Accept":"application/vnd.github+json"}
    Create Session    gemini    ${GEMINI_URL}?key=${GEMINI_KEY}
    Remove File    ${LOG_FILE}
    Append To File    ${LOG_FILE}    ===== LOGS DE EXECUÇÃO =====\n

Finalizar Ambiente
    Close All Browsers

Registrar Log
    [Arguments]    ${mensagem}
    Append To File    ${LOG_FILE}    ${mensagem}\n
    Log    ${mensagem}

Executar Fluxo Padrao
    [Arguments]    ${cenario}

    Registrar Log    Iniciando cenário: ${cenario}
    Abrir Navegador
    Realizar Fluxo Da Pagina    ${cenario}
    ${print}=    Capture Page Screenshot
    Registrar Log    Screenshot salvo: ${print}
    ${resultado}=    Enviar Log Ao Gemini
    Criar Issue No GitHub    ${cenario}    ${resultado}
    Registrar Log    Cenário finalizado: ${cenario}
    Close Browser

Abrir Navegador
    Open Browser    ${BASE_URL}    ${BROWSER}
    Maximize Browser Window

Realizar Fluxo Da Pagina
    [Arguments]    ${cenario}

    Run Keyword If    '${cenario}' == 'Login'            Executar Login
    Run Keyword If    '${cenario}' == 'Upload'           Executar Upload
    Run Keyword If    '${cenario}' == 'Download'         Executar Download
    Run Keyword If    '${cenario}' == 'Dynamic Loading'  Executar Dynamic Loading

    Registrar Log    Fluxo executado com sucesso: ${cenario}

Executar Login
    Go To    ${BASE_URL}/login
    Input Text    id=username    tomsmith
    Input Text    id=password    SuperSecretPassword!
    Click Button    class=radius

Executar Upload
    Go To    ${BASE_URL}/upload
    Choose File    id=file-upload    ${CURDIR}/arquivo_teste.txt
    Click Button    id=file-submit

Executar Download
    Go To    ${BASE_URL}/download
    Click Link    some-file.txt

Executar Dynamic Loading
    Go To    ${BASE_URL}/dynamic_loading/2
    Click Button    css=div#start button
    Wait Until Page Contains    Hello World!    timeout=15s

Enviar Log Ao Gemini
    ${conteudo}=    Get File    ${LOG_FILE}

    ${payload}=    Create Dictionary
    ...    contents=[{"parts":[{"text":"Analise este log de testes e gere um resumo profissional:\n\n${conteudo}"}]}]

    ${response}=    POST On Session    gemini    data=${payload}    headers={"Content-Type": "application/json"}
    ${resposta}=    Set Variable    ${response.json()["candidates"][0]["content"]["parts"][0]["text"]}

    Registrar Log    Resposta Gemini: ${resposta}

    [Return]    ${resposta}

Criar Issue No GitHub
    [Arguments]    ${cenario}    ${analise}

    ${payload}=    Create Dictionary
    ...    title=Automação: Resultado do cenário ${cenario}
    ...    body=${analise}

    ${response}=    POST On Session    github    json=${payload}
    Registrar Log    Issue criada com status: ${response.status_code}
