*** Settings ***
Library    RequestsLibrary
Library    Collections

*** Variables ***
${BASE_URL}    https://the-internet.herokuapp.com

*** Test Cases ***
Validar Status Code 200
    Create Session    api    ${BASE_URL}
    ${response}=    GET    api    /status_codes/200
    Should Be Equal As Integers    ${response.status_code}    200

Validar Status Code 404
    Create Session    api    ${BASE_URL}
    Run Keyword And Expect Error    *404*    GET    api    /status_codes/404

Validar Status Code 500
    Create Session    api    ${BASE_URL}
    Run Keyword And Expect Error    *500*    GET    api    /status_codes/500

Testar Endpoint com Delay
    Create Session    api    ${BASE_URL}
    ${response}=    GET    api    /delay/2
    Should Be Equal As Integers    ${response.status_code}    200
