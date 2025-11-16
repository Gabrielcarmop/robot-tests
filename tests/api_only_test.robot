*** Settings ***
Library    RequestsLibrary
Suite Setup    Create Session    api    https://the-internet.herokuapp.com

*** Test Cases ***
Validar Status Code 200
    ${resp}=    GET    api    /status_codes/200
    Should Be Equal As Integers    ${resp.status_code}    200

Validar Status Code 404
    ${resp}=    GET    api    /status_codes/404
    Should Be Equal As Integers    ${resp.status_code}    404

Validar Status Code 500
    ${resp}=    GET    api    /status_codes/500
    Should Be Equal As Integers    ${resp.status_code}    500

Testar Endpoint com Delay
    ${resp}=    GET    api    /delay/3
    Should Be Equal As Integers    ${resp.status_code}    200
