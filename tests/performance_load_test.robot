*** Settings ***
Library    RequestsLibrary
Suite Setup    Create Session    api    https://the-internet.herokuapp.com

*** Variables ***
${LOAD_REQUESTS}       50

*** Test Cases ***
Teste de Carga Leve (50 Requisições)
    FOR    ${i}    IN RANGE    ${LOAD_REQUESTS}
        ${resp}=    GET    api    /status_codes/200
        Should Be Equal As Integers    ${resp.status_code}    200
    END
