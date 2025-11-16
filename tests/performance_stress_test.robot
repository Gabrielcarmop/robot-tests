*** Settings ***
Library    RequestsLibrary
Suite Setup    Create Session    api    https://the-internet.herokuapp.com

*** Variables ***
${STRESS_REQUESTS}    200

*** Test Cases ***
Teste de Stress (200 Requisições)
    FOR    ${i}    IN RANGE    ${STRESS_REQUESTS}
        ${resp}=    GET    api    /status_codes/200
        Should Be Equal As Integers    ${resp.status_code}    200
    END
