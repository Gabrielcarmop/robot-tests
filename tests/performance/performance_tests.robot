*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    OperatingSystem

Suite Setup       Setup Performance Suite
Suite Teardown    Close All Sessions

*** Variables ***
${BASE_API}          https://the-internet.herokuapp.com
${GEMINI_KEY}        AIzaSyB0EIY589GB0hxd4QiD2MDJfdlNAG-Htzk
${GITHUB_TOKEN}      %{MY_GITHUB_TOKEN}
${GITHUB_REPO}       Gabrielcarmop/robot-tests


*** Keywords ***
Setup Performance Suite
    Create Session    api    ${BASE_API}    verify=False
    Log To Console    Iniciando suite de performance...


Enviar Requisicao Status
    [Arguments]    ${codigo}
    ${resposta}=    GET    api    /status_codes/${codigo}
    RETURN    ${resposta.status_code}


Enviar Requisicoes Em Lote
    [Arguments]    ${quantidade}
    FOR    ${i}    IN RANGE    ${quantidade}
        ${resposta}=    GET    api    /status_codes/200
        Should Be Equal As Integers    ${resposta.status_code}    200
    END


Analisar Com Gemini
    [Arguments]    ${conteudo}
    ${payload}=    Create Dictionary
    ...    contents=${[{ "parts": [{ "text": "${conteudo}" }] }]}
    Create Session    gemini    https://generativelanguage.googleapis.com
    ${resp}=    POST    gemini    /v1beta/models/gemini-1.5-flash:generateContent?key=${GEMINI_KEY}
    ...    json=${payload}
    Should Be Equal As Integers    ${resp.status_code}    200
    RETURN    ${resp.json()}


Criar Issue No GitHub
    [Arguments]    ${titulo}    ${corpo}
    ${payload}=    Create Dictionary    title=${titulo}    body=${corpo}
    Create Session    github    https://api.github.com
    ${headers}=    Create Dictionary    Authorization=Bearer ${GITHUB_TOKEN}
    ${resp}=    POST    github    /repos/${GITHUB_REPO}/issues    json=${payload}    headers=${headers}
    Should Be Equal As Integers    ${resp.status_code}    201


*** Test Cases ***

Teste API-only - Status 200
    ${code}=    Enviar Requisicao Status    200
    Should Be Equal As Integers    ${code}    200

Teste API-only - Status 404
    Run Keyword And Expect Error    *404*    GET    api    /status_codes/404

Teste API-only - Status 500
    Run Keyword And Expect Error    *500*    GET    api    /status_codes/500

Teste API-only - Delay
    ${resp}=    GET    api    /delay/2
    Should Be Equal As Integers    ${resp.status_code}    200


*** Test Cases ***
Teste de Carga Simples (50 req)
    Enviar Requisicoes Em Lote    50

Teste de Stress (200 req)
    Enviar Requisicoes Em Lote    200

Teste Gemini - Analisar Resultado
    ${resultado}=    Analisar Com Gemini    "Todos os testes passaram?"
    Log    ${resultado}

Teste GitHub - Criar Issue Automática
    Criar Issue No GitHub    "Teste automático"    "Issue criada via Robot Framework"
