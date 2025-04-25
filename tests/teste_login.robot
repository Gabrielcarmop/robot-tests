*** Settings ***
Library    SeleniumLibrary

*** Variables ***
${URL}        https://sso.ufg.br/cas/login?service=https://cerberus.api.ufg.br/portal/cas/login
${BROWSER}    chrome

*** Test Cases ***
Acessar Página de Login da UFG
    Open Browser    ${URL}    ${BROWSER}
    Wait Until Page Contains Element    id=username
    Input Text    id=username    username
    Input Text    id=password    password
    Click Button    name=submit
    Sleep    3
    Capture Page Screenshot
    Close Browser
