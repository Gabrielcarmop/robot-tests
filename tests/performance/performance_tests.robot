*** Settings ***
Documentation    Testes de performance e carga utilizando API do The Internet.
Library          RequestsLibrary
Library          OperatingSystem
Library          Collections
Library          String
Library          BuiltIn

Suite Setup      Create Session    theinternet    https://the-internet.herokuapp.com

*** Variables ***
${USERS}          50
${RAMP_UP}        5
${ENDPOINT}       /status_codes/200
${GEMINI_URL}     https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent
${GEMINI_KEY}     AIzaSyB0EIY589GB0hxd4QiD2MDJfdlNAG-Htzk
${GITHUB_API}     https://api.github.com/repos/Gabrielcarmop/robot-tests/issues
${GITHUB_TOKEN}   %{MY_GITHUB_TOKEN}

*** Test Cases ***
Teste de Carga Simples
    [Documentation]    Dispara diversas requisições ao endpoint /status_codes/200
    FOR    ${i}    IN RANGE    ${USERS}
        ${resp}=    GET On Session    theinternet    ${ENDPOINT}
        Should Be Equal As Integers    ${resp.status_code}    200
    END

Teste de Estresse - Aumento Gradual
    [Documentation]    Aumenta gradualmente a carga de requests.
    FOR    ${i}    IN RANGE    ${RAMP_UP}
        Log To Console    ---- Rodada ${i} ----
        FOR    ${j}    IN RANGE    ${i * 10}
            ${resp}=    GET On Session    theinternet    ${ENDPOINT}
            Should Be Equal As Integers    ${resp.status_code}    200
        END
    END

Teste API-only - Retornar status code
    ${resp}=    GET On Session    theinternet    /status_codes/404
    Should Be Equal As Integers    ${resp.status_code}    404

Teste Gemini - Analisar Resultado do Teste
    ${body}=    Create Dictionary
    ...         contents=[{"role":"user","parts":[{"text":"Explique o que significa um teste de carga simples em QA"}]}]
    ${url}=     Set Variable    ${GEMINI_URL}?key=${GEMINI_KEY}
    ${resp}=    Post Request    theinternet    ${url}    json=${body}
    Should Be Equal As Integers    ${resp.status_code}    200

Teste GitHub - Criar Issue Automática
    ${headers}=    Create Dictionary    Authorization=Bearer ${GITHUB_TOKEN}
    ${payload}=    Create Dictionary    title=Bug detectado no teste de carga    body=Falha ao executar teste de performance
    ${resp}=       Post Request    theinternet    ${GITHUB_API}    json=${payload}    headers=${headers}
    Should Be True    ${resp.status_code} == 201 or ${resp.status_code} == 200


*** Keywords ***
Post Request
    [Arguments]    ${session}    ${url}    ${json}    ${headers}=
    ${resp}=    POST    ${url}    json=${json}    headers=${headers}
    [Return]    ${resp}
